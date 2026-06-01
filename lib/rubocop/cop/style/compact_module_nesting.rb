# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Enforces a compact outer module namespace with a separately nested
      # innermost class.
      #
      # When the innermost definition in a wrapper chain is a `class`, the
      # outer modules are collapsed into a single compact `module A::B`
      # wrapping the class. When the chain is entirely modules, every
      # segment is collapsed into a single compact `module A::B::C`
      # wrapping the body directly.
      #
      # The canonical form is one `module A::B::C` line wrapping a single
      # nested innermost `class D`:
      #
      #   module A::B::C
      #     class D
      #     end
      #   end
      #
      # @example
      #   # bad
      #   module A
      #     module B
      #       class C
      #       end
      #     end
      #   end
      #
      #   # bad
      #   class A::B::C
      #   end
      #
      #   # good
      #   module A::B
      #     class C
      #     end
      #   end
      #
      #   # good (no namespace)
      #   class Foo
      #   end
      class CompactModuleNesting < Base
        extend AutoCorrector

        MSG_NESTING        = 'Use compact outer module nesting: `%<canonical>s`.'
        MSG_MULTIPLE_ROOTS = 'Only one top-level module or class is allowed per file.'

        def on_module(node)
          handle(node)
        end

        def on_class(node)
          handle(node)
        end

        def on_new_investigation
          check_multiple_top_level_definitions
        end

        private

        # Process only outermost definitions; nested wrappers are reached via the
        # collected chain.
        def handle(node)
          return if nested_inside_definition?(node)

          chain = collect_wrapper_chain(node)
          return unless chain

          segments  = chain[:segments]
          innermost = chain[:innermost]

          if innermost.class_type?
            # Skip when there's no nested innermost AND no class-path to split.
            return if node.equal?(innermost) && !requires_split?(node, segments, innermost)

            return unless segments.size >= 2

            outer_segments = segments[0..-2]
            inner_segment  = segments.last
            inner_keyword  = :class

            return if canonical?(node, innermost, outer_segments, inner_segment, inner_keyword)

            register_offense(node, innermost, outer_segments, inner_segment, inner_keyword)
          else
            # Module-only chain: collapse all segments into a single
            # `module A::B::C` wrapping the body directly.
            return if node.equal?(innermost)
            return unless segments.size >= 2

            register_offense(node, innermost, segments, nil, nil)
          end
        end

        def nested_inside_definition?(node)
          parent = node.parent
          return false unless parent

          parent.module_type? || parent.class_type?
        end

        # Walk a chain of `module`/`class` nodes whose body is a single nested
        # definition, gathering all namespace segments. Returns nil if the
        # outermost is not part of any namespaced structure worth checking.
        #
        # Returns a hash: { segments: [String, ...], innermost: Node }
        def collect_wrapper_chain(node)
          segments = []
          current  = node

          loop do
            const_path = constant_path(current.identifier)
            return nil unless const_path

            segments.concat(const_path)

            body = current.body
            if body && (body.module_type? || body.class_type?) && current.module_type?
              # Only modules may act as namespace wrappers in our style; a class
              # cannot wrap another definition this way.
              current = body
              next
            end

            return { segments: segments, innermost: current }
          end
        end

        # Splits a const node like `A::B::C` into ['A', 'B', 'C'].
        # Returns nil for `self::Foo`, `cbase`-rooted (`::A::B` is fine), or
        # anything else non-trivial.
        def constant_path(const_node)
          return nil unless const_node&.const_type?

          parts = []
          current = const_node

          while current&.const_type?
            parts.unshift(current.short_name.to_s)
            scope = current.namespace
            if scope.nil?
              return parts
            elsif scope.cbase_type?
              # leading `::` — treat as absolute, still valid namespace path
              return parts
            elsif scope.const_type?
              current = scope
            else
              # e.g. `self::Foo`
              return nil
            end
          end

          parts
        end

        def requires_split?(node, segments, innermost)
          # `class A::B::C` (single class node with multi-segment path) needs
          # to be split into `module A::B` + `class C`.
          return false unless segments.size >= 2

          node.equal?(innermost) && node.class_type?
        end

        def canonical?(outer, innermost, outer_segments, inner_segment, inner_keyword)
          return false unless outer.module_type?
          return false unless innermost.send(:"#{inner_keyword}_type?")

          outer_path = constant_path(outer.identifier)
          inner_path = constant_path(innermost.identifier)

          outer_path == outer_segments &&
            inner_path == [inner_segment] &&
            outer.body.equal?(innermost) &&
            outer_segments.any?
        end

        def register_offense(node, innermost, outer_segments, inner_segment, inner_keyword)
          canonical_source = build_canonical_source(node, innermost, outer_segments, inner_segment, inner_keyword)
          first_line = canonical_source.lines.first.strip

          add_offense(node, message: format(MSG_NESTING, canonical: first_line)) do |corrector|
            corrector.replace(node, canonical_source)
          end
        end

        def build_canonical_source(node, innermost, outer_segments, inner_segment, inner_keyword)
          base_indent  = ' ' * node.loc.expression.column
          outer_const  = outer_segments.join('::')

          lines = ["module #{outer_const}"]

          if inner_keyword
            inner_indent = "#{base_indent}  "
            body_source  = inner_body_source(innermost, inner_indent)

            lines << "#{inner_indent}#{inner_keyword} #{inner_segment}"
            lines << body_source unless body_source.empty?
            lines << "#{inner_indent}end"
          else
            body_source = inner_body_source(innermost, base_indent)
            lines << body_source unless body_source.empty?
          end

          lines << "#{base_indent}end"

          # First line already sits at `base_indent` in the source we're
          # replacing; subsequent lines need explicit indentation, which we've
          # baked in above. Just join.
          lines.join("\n")
        end

        # Re-indents the body of the innermost definition so it sits two spaces
        # deeper than the new inner keyword line. Returns "" if there is no
        # body.
        def inner_body_source(innermost, inner_indent)
          body = innermost.body
          return '' unless body

          body_indent = "#{inner_indent}  "
          original    = body.source
          original_col = body.loc.expression.column
          shift        = body_indent.length - original_col

          original.lines.map.with_index do |line, idx|
            if idx.zero?
              "#{body_indent}#{line.chomp}"
            elsif line.strip.empty?
              line.chomp
            elsif shift.positive?
              "#{' ' * shift}#{line.chomp}"
            elsif shift.negative?
              line.chomp.sub(/\A {0,#{-shift}}/, '')
            else
              line.chomp
            end
          end.join("\n")
        end

        def check_multiple_top_level_definitions
          root = processed_source.ast
          return unless root

          top_defs =
            if root.begin_type?
              root.children.select { |c| c.respond_to?(:type) && (c.class_type? || c.module_type?) }
            elsif root.class_type? || root.module_type?
              [root]
            else
              []
            end

          return if top_defs.size <= 1

          top_defs.drop(1).each do |extra|
            add_offense(extra, message: MSG_MULTIPLE_ROOTS)
          end
        end
      end
    end
  end
end
