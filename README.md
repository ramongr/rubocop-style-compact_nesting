# rubocop-style-compact_nesting

A RuboCop plugin that enforces a hybrid module/class nesting style:

- All namespace segments are **collapsed onto a single `module` line** using
  `::`.
- When the innermost definition in a wrapper chain is a `class`, that class
  is **nested separately** inside the compact `module` wrapper.
- When the chain is entirely modules, every segment is collapsed into a
  single compact `module A::B::C` wrapping the body directly.

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
# bad
module A
  module B
    module C
    end
  end
end

# good (module-only chain collapses to one compact module)
module A::B::C
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
```

The plugin disables `Style/ClassAndModuleChildren` by default because that
cop enforces the opposite layout. If you want it back, re-enable it in
your own config:

```yaml
Style/ClassAndModuleChildren:
  Enabled: true
```

Requires RuboCop `>= 1.72` and Ruby `>= 3.1`.

## Rules

### `Style/CompactModuleNesting`

- Detects chains of wrapper modules whose body is a single nested
  module/class ending in a `class`, and rewrites them to one compact outer
  `module A::B::C` with a separately nested innermost `class D`.
- Rewrites `class A::B::C` to `module A::B; class C; end; end`.
- Collapses pure module-only chains into a single compact
  `module A::B::C` wrapping the body directly.
- Flags (without autocorrect) files that define more than one top-level
  module/class.
- Ignores bare top-level classes/modules with no namespace.
- Ignores wrapper modules whose body contains anything besides a single
  nested definition (e.g. constants, methods, or sibling classes).

## License

MIT
