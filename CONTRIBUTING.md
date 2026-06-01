# Contributing

## Development

```sh
bundle install
bundle exec rake test       # Minitest suite
bundle exec rubocop         # lint
```

The Minitest suite lives under `test/` and uses the helpers in
`test/test_helper.rb`. Add new cop scenarios as `assert_offense` /
`assert_no_offenses` / `assert_correction` cases.

## Pull requests

`main` is protected: direct pushes are blocked and CI (`Minitest (Ruby
3.1)`...`Minitest (Ruby 3.4)`, `RuboCop`) must pass on every PR. Create a
branch, push, and open a PR:

```sh
git checkout -b my/change
# ...edits...
git push -u origin my/change
gh pr create --base main --fill
```

Squash-merge is the default. Keep commits focused and write a short, real
description in the PR body.

## Releasing

Releases are tag-driven and automated end-to-end. To publish version
`X.Y.Z`:

1. Bump `VERSION` in `lib/rubocop/style/compact_nesting/version.rb`.
2. Add a `[X.Y.Z] - YYYY-MM-DD` entry at the top of `CHANGELOG.md`.
3. Open a PR with both changes; merge once CI is green.
4. Tag and push:

   ```sh
   git checkout main && git pull
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

The `Release` workflow (`.github/workflows/release.yml`) will:

- Run the test suite one more time.
- Exchange a GitHub OIDC token for short-lived RubyGems credentials via
  the existing **trusted publisher** for this repo.
- Build the gem from `rubocop-style-compact_nesting.gemspec` and `gem
  push` it to RubyGems.
- Create a GitHub Release with auto-generated notes and the `.gem`
  attached as an asset.

No long-lived RubyGems API key is stored anywhere.

### Re-running a failed release

Tag pushes are the trigger. If the release job fails for a transient
reason, re-run it from the existing tag:

```sh
gh workflow run release.yml --ref vX.Y.Z
```
