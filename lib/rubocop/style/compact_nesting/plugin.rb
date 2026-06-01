# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module Style
    module CompactNesting
      # A RuboCop plugin (LintRoller) that registers the
      # `Style/CompactModuleNesting` cop and its default configuration.
      class Plugin < LintRoller::Plugin
        def about
          LintRoller::About.new(
            name: 'rubocop-style-compact_nesting',
            version: VERSION,
            homepage: 'https://github.com/ramongr/rubocop-style-compact_nesting',
            description: 'Enforce compact outer module nesting with a separately ' \
                         'nested innermost class/module.'
          )
        end

        def supported?(context)
          context.engine == :rubocop
        end

        def rules(_context)
          project_root = Pathname.new(__dir__).join('..', '..', '..', '..').expand_path

          LintRoller::Rules.new(
            type: :path,
            config_format: :rubocop,
            value: project_root.join('config', 'default.yml')
          )
        end
      end
    end
  end
end
