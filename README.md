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

## Debugging

Adding `--verbose` to the `build` or `serve` command may provide additional information.

## Cache options when running locally

If you are in a slow network, or the remote theme is so big that you don't want to download it every time, you can specify options in `_config.yml` to enable cache. If you only want to enable cache in development environment, you can create `_config.dev.yml`, and specify it in `serve` command like `jekyll serve -c _config.yml,_config.dev.yml`, this will make jekyll override the options from `_config.yml`.

```yml
remote_theme_cache_enabled: true
remote_theme_cache_dir: <SPECIFIED_CACHE_DIR>
```

Add above options in your `_config.yml` file. By default the `remote_theme_cache_dir` is `~/.jekyll-remote-theme-cache`. Then start your server locally, the first time it will download the theme. After that, it will use the cache.
