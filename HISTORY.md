# History

## Unreleased

### Fixes

- Document the Enterprise hostname allowlist and explain how to allow a rejected
  host in the invalid-theme error (#168)

## 0.6.2

Maintenance release: no runtime behavior changes.

### Documentation

- Add a gemspec description and RubyGems metadata (homepage, source code,
  bug tracker, and changelog links), and lead the README with the same
  one-line description (#155)

## 0.6.1

### Security

- Reject local theme paths when the site is built in safe mode, so a site's
  `_config.yml` can't read files from outside the site on the build host
  ([GHSA-3343-386p-v26g](https://github.com/benbalter/jekyll-remote-theme/security/advisories/GHSA-3343-386p-v26g))

## 0.6.0

### Security

- Cap the download size while streaming, so chunked responses without a
  `Content-Length` header are limited too (#152)
- Reject zip entries that inflate past their declared size, and cap the total
  extracted size at 2 GB (#152)

### Fixes

- Honor `NO_PROXY`/`no_proxy`, and use `HTTPS_PROXY` for the `@latest`
  release lookup as well as the download (#152)
- Stop registering a new `at_exit` handler and theme temp directory on every
  `jekyll serve` rebuild (#152)

### Changes

- Add a 10-second open timeout and a 60-second read timeout to GitHub
  requests (#152)

### Dependencies

- Declare `required_ruby_version >= 3.0` (#145)

### Infrastructure

- Bump `github/codeql-action` (#146, #147, #149)

## 0.5.2

### Fixes

- Fix jekyll-github-metadata 2.15.0+ compatibility when loaded as a theme
  dependency (#128)

### Dependencies

- Allow rubyzip 3.x (`>= 1.3.0, < 4.0`) and make archive extraction compatible
  with rubyzip's 3.0 API change (#139)

### Infrastructure

- Relax the `rubocop-ast` pin (#134, #138)
- Bump `actions/checkout` to v7 (#137)

## 0.5.1

### Fixes

- Fix RuboCop load failure on Ruby 4.0
- Add base64 dependency for Ruby 3.4+

### Dependencies

- Allow openssl 4.x to fix install on Ruby 4.0 (#133)
- Bump github/codeql-action from 3 to 4 (#130)

### Infrastructure

- Test CI against Ruby 4.0
- Exclude Ruby 4.0 + Jekyll 3.x from CI matrix
- Upgrade RuboCop to 1.57 and resolve violations
- Pin rubocop-ast below 1.38 to avoid deprecation warning

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
