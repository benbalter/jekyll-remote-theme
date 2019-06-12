# Jekyll Remote Theme

Jekyll plugin for building Jekyll sites with any public GitHub-hosted theme

[![Gem Version](https://badge.fury.io/rb/jekyll-remote-theme.svg)](https://badge.fury.io/rb/jekyll-remote-theme) [![Build Status](https://travis-ci.org/benbalter/jekyll-remote-theme.svg?branch=master)](https://travis-ci.org/benbalter/jekyll-remote-theme) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)


## Usage

1. Add the following to your Gemfile

  ```ruby
  gem "jekyll-remote-theme"
  ```

  and run `bundle install` to install the plugin

2. Add the following to your site's `_config.yml` to activate the plugin

  ```yml
  plugins:
    - jekyll-remote-theme
  ```
  Note: If you are using a Jekyll version less than 3.5.0, use the `gems` key instead of `plugins`.

3. Add the following to your site's `_config.yml` to choose your theme

  ```yml
  remote_theme: benbalter/retlab
  ```

## Declaring your theme

Remote themes are specified by the `remote_theme` key in the site's config.

Remote themes must be in the form of `OWNER/REPOSITORY`, and must represent a public GitHub-hosted Jekyll theme. See [the Jekyll documentation](https://jekyllrb.com/docs/themes/) for more information on authoring a theme. Note that you do not need to upload the gem to RubyGems or include a `.gemspec` file.

You may also optionally specify a branch, tag, or commit to use by appending an `@` and the Git ref (e.g., `benbalter/retlab@v1.0.0` or `benbalter/retlab@develop`). If you don't specify a Git ref, the `master` branch will be used.

## Caching

If you are using Jekyll Version 4.0 or later, by default, the remote theme is cached to speed up builds.

To disable the cache entirely, change your config to the following:

```yaml
remote_theme:
  theme: benbalter/retlab
  cache: false
```

The cache will expire after 1 hour. You can set the cache's TTL (in seconds), by change your config to the following:

```yaml
remote_theme:
  theme: benbalter/retlab
  ttl: 60 # 1 minute
```
## Debugging

Adding `--verbose` to the `build` or `serve` command may provide additional information.
