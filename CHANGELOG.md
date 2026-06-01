# Changelog

## [0.1.0] - 2026-06-01

### Added
- Initial release.
- `Style/CompactModuleNesting` cop with safe autocorrect:
  - Collapses outer module wrappers around an innermost class into a single
    compact `module A::B` with the class nested separately.
  - Splits `class A::B::C` into `module A::B; class C; end; end`.
  - Collapses pure module-only chains into a single compact
    `module A::B::C` wrapping the body directly.
  - Flags files with more than one top-level module/class.
