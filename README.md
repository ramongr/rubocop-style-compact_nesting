# rubocop-style-compact_nesting

A RuboCop plugin that enforces a hybrid module/class nesting style for files
that define a class inside a namespace:

- All namespace segments are **collapsed onto a single `module` line** using
  `::`.
- The innermost `class` is **nested separately** inside that wrapper.

The rule only fires when the innermost definition in a wrapper chain is a
`class`. A pure module-with-submodules hierarchy (no class at the bottom) is
left alone.

## Canonical form

```ruby
module A::B::C
  class D
    # ...
  end
end
```

## Examples

```ruby
# bad
module A
  module B
    class C
      # ...
    end
  end
end

# good
module A::B
  class C
    # ...
  end
end
```

```ruby
# bad
class A::B::C
  # ...
end

# good
module A::B
  class C
    # ...
  end
end
```

```ruby
# good (no namespace)
class Foo
  # ...
end
```

```ruby
# good (no class at the bottom — just submodules)
module A
  module B
    module C
    end
  end
end
```

## Installation

```ruby
# Gemfile
gem 'rubocop-style-compact_nesting', require: false
```

```yaml
# .rubocop.yml
plugins:
  - rubocop-style-compact_nesting

# This cop conflicts with the built-in Style/ClassAndModuleChildren.
Style/ClassAndModuleChildren:
  Enabled: false
```

Requires RuboCop `>= 1.72` and Ruby `>= 3.1`.

## Rules

### `Style/CompactModuleNesting`

- Detects chains of wrapper modules whose body is a single nested
  module/class ending in a `class`, and rewrites them to one compact outer
  `module A::B::C` with a separately nested innermost `class D`.
- Rewrites `class A::B::C` to `module A::B; class C; end; end`.
- Flags (without autocorrect) files that define more than one top-level
  module/class.
- Ignores bare top-level classes/modules with no namespace.
- Ignores submodule-only hierarchies (no class at the bottom).
- Ignores wrapper modules whose body contains anything besides a single
  nested definition (e.g. constants, methods, or sibling classes).

## License

MIT
