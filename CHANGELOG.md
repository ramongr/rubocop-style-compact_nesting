# Changelog

## [0.1.2] - 2026-06-01

### Changed
- README now ships with gem version, CI status, downloads, and license
  badges.

### Added
- Regression test pinning the plugin's default config behaviour.

### Internal
- Ruby 4.0 (preview) added to the CI matrix as a non-blocking job.
- `CONTRIBUTING.md` documenting the dev loop, PR flow, and tag-driven
  release process.

## [0.1.1] - 2026-06-01

### Changed
- Plugin default config now disables `Style/ClassAndModuleChildren`. That
  cop enforces the opposite layout of `Style/CompactModuleNesting`, so the
  two would always disagree. Users who want `Style/ClassAndModuleChildren`
  can re-enable it explicitly in their own `.rubocop.yml`.

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
