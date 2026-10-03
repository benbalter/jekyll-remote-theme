# CLAUDE.md

Jekyll plugin to build a site with any public GitHub-hosted theme, set via the `remote_theme` config key. Published to RubyGems as [`jekyll-remote-theme`](https://rubygems.org/gems/jekyll-remote-theme).

## Commands

- [`script/bootstrap`](script/bootstrap) installs dependencies.
- Run [`script/cibuild`](script/cibuild) before committing. It runs RSpec, RuboCop and `gem build`, as [CI](.github/workflows/ci.yml) does.
- CI also tests Jekyll 3 and 4. Set `JEKYLL_VERSION` (for example `JEKYLL_VERSION="~> 3.0"`) before `script/bootstrap` and `script/cibuild` to match a CI job.
- Run RuboCop as `bundle exec rubocop lib spec *.gemspec`, never bare. A bare run walks CI's in-repo `vendor/bundle` and crashes on a dependency's config.

## Releasing

- Pushing a `v*` tag runs [`release.yml`](.github/workflows/release.yml), which publishes the gem to RubyGems immediately and creates a GitHub Release. A published version can't be replaced.
- The owner cuts releases with [jekyll-release-tools](https://github.com/benbalter/jekyll-release-tools), and only after explicitly approving the release.
- When asked, agents may prepare a version-bump PR that updates [`lib/jekyll-remote-theme/version.rb`](lib/jekyll-remote-theme/version.rb) and [`HISTORY.md`](HISTORY.md).
- Agents never create or push tags, run `rake release` or `gem push`, or create a GitHub Release.
- Push branches with `git push --no-follow-tags`, so an annotated tag on a commit doesn't go out with the branch.
