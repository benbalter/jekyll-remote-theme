# History

## 0.5.0

### Features

- Add `@latest` ref to automatically use the latest GitHub release (#126)
- Add support for local filesystem paths in `remote_theme` configuration (#120)
- Add corporate proxy support for remote theme downloads (#124)

### Fixes

- Improve 404 error message for non-existent remote themes (#110)
- Fix Ruby 3.4 SSL/CRL compatibility issue (#118)
- Fix compatibility with jekyll-github-metadata 2.15.0+ (#122)
- Add gemspec metadata methods to `MockGemspec` for remote theme compatibility (#125)
- Add tests and documentation for local file override behavior (#123)

### Dependencies

- Bump jekyll-sass-converter to allow 3.1.0 (#127)
- Bump actions/checkout from 2 to 6 (#115)
- Bump github/codeql-action from 1 to 3 (#108)
- Upgrade to GitHub-native Dependabot (#92)

### Infrastructure

- Move from Travis to GitHub Actions for CI (#106)

## 0.4.3

See [the GitHub release notes](https://github.com/benbalter/jekyll-remote-theme/releases/tag/v0.4.3).
