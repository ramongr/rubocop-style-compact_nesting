# frozen_string_literal: true

require_relative '../../../test_helper'

class CompactModuleNestingTest < CopTestCase
  cop RuboCop::Cop::Style::CompactModuleNesting

  # -- canonical form ---------------------------------------------------------

  def test_canonical_module_with_nested_class
    assert_no_offenses(<<~RUBY)
      module A::B
        class C
        end
      end
    RUBY
  end

  def test_single_module_with_nested_class
    assert_no_offenses(<<~RUBY)
      module A
        class B
        end
      end
    RUBY
  end

  def test_three_segment_module_with_nested_class
    assert_no_offenses(<<~RUBY)
      module A::B::C
        class D
          attr_reader :x
        end
      end
    RUBY
  end

  def test_compact_module_with_nested_module_is_collapsed
    source = <<~RUBY
      module A::B
        module C
        end
      end
    RUBY

    assert_offense(source, message: 'Use compact outer module nesting: `module A::B::C`.')
    assert_correction(source, <<~RUBY)
      module A::B::C
      end
    RUBY
  end

  # -- no namespace -----------------------------------------------------------

  def test_bare_top_level_class
    assert_no_offenses(<<~RUBY)
      class Foo
      end
    RUBY
  end

  def test_bare_top_level_module
    assert_no_offenses(<<~RUBY)
      module Foo
      end
    RUBY
  end

  # -- no class at the bottom -------------------------------------------------

  # -- module-only chains are collapsed --------------------------------------

  def test_submodule_only_chain_is_collapsed
    source = <<~RUBY
      module A
        module B
          module C
          end
        end
      end
    RUBY

    assert_offense(source, message: 'Use compact outer module nesting: `module A::B::C`.')
    assert_correction(source, <<~RUBY)
      module A::B::C
      end
    RUBY
  end

  def test_submodule_chain_with_constants_is_collapsed
    source = <<~RUBY
      module A
        module B
          module C
            FOO = 1
          end
        end
      end
    RUBY

    assert_offense(source, message: 'Use compact outer module nesting: `module A::B::C`.')
    assert_correction(source, <<~RUBY)
      module A::B::C
        FOO = 1
      end
    RUBY
  end

  # -- no inner definition ----------------------------------------------------

  def test_compact_module_alone_no_inner
    assert_no_offenses(<<~RUBY)
      module A::B::C
      end
    RUBY
  end

  # -- fully expanded nesting -------------------------------------------------

  def test_flags_and_corrects_two_levels_of_wrapping
    source = <<~RUBY
      module A
        module B
          class C
          end
        end
      end
    RUBY

    assert_offense(source, message: 'Use compact outer module nesting: `module A::B`.')
    assert_correction(source, <<~RUBY)
      module A::B
        class C
        end
      end
    RUBY
  end

  def test_flags_and_corrects_three_levels_of_wrapping
    source = <<~RUBY
      module A
        module B
          module C
            class D
            end
          end
        end
      end
    RUBY

    assert_offense(source, message: 'Use compact outer module nesting: `module A::B::C`.')
    assert_correction(source, <<~RUBY)
      module A::B::C
        class D
        end
      end
    RUBY
  end

  def test_preserves_class_body
    source = <<~RUBY
      module A
        module B
          class C
            attr_reader :x

            def call
              42
            end
          end
        end
      end
    RUBY

    assert_offense(source)
    assert_correction(source, <<~RUBY)
      module A::B
        class C
          attr_reader :x

          def call
            42
          end
        end
      end
    RUBY
  end

  # -- mixed compact + nested wrappers ----------------------------------------

  def test_module_a_wrapping_module_bc_with_class
    source = <<~RUBY
      module A
        module B::C
          class D
          end
        end
      end
    RUBY

    assert_offense(source, message: 'Use compact outer module nesting: `module A::B::C`.')
    assert_correction(source, <<~RUBY)
      module A::B::C
        class D
        end
      end
    RUBY
  end

  def test_module_ab_wrapping_module_c_with_class
    source = <<~RUBY
      module A::B
        module C
          class D
          end
        end
      end
    RUBY

    assert_offense(source, message: 'Use compact outer module nesting: `module A::B::C`.')
    assert_correction(source, <<~RUBY)
      module A::B::C
        class D
        end
      end
    RUBY
  end

  # -- compact class form -----------------------------------------------------

  def test_flags_and_splits_class_with_compact_path
    source = <<~RUBY
      class A::B::C
      end
    RUBY

    assert_offense(source, message: 'Use compact outer module nesting: `module A::B`.')
    assert_correction(source, <<~RUBY)
      module A::B
        class C
        end
      end
    RUBY
  end

  def test_flags_and_splits_class_with_compact_path_and_body
    source = <<~RUBY
      class A::B::C
        attr_reader :x
      end
    RUBY

    assert_offense(source)
    assert_correction(source, <<~RUBY)
      module A::B
        class C
          attr_reader :x
        end
      end
    RUBY
  end

  # -- wrapper module with sibling code ---------------------------------------

  def test_wrapper_module_with_mixed_body_is_left_alone
    assert_no_offenses(<<~RUBY)
      module A
        CONST = 1

        class B
        end
      end
    RUBY
  end

  # -- multiple top-level definitions -----------------------------------------

  def test_flags_extra_top_level_definitions
    source = <<~RUBY
      module A
        class B
        end
      end

      module C
        class D
        end
      end
    RUBY

    offenses = assert_offense(source)
    assert(
      offenses.any? { |o| o.message == 'Only one top-level module or class is allowed per file.' },
      "Expected multiple-roots message, got: #{offenses.map(&:message).inspect}"
    )
  end
end
