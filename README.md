# Jekyll Remote Theme

Jekyll plugin for building Jekyll sites with any GitHub-hosted theme

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

3. Add the following to your site's `_config.yml` to choose your theme

  ```yml
  remote_theme: benbalter/retlab
  ```

## Declaring your theme

Remote themes are specified by the `remote_theme` key in the site's config.

Remote themes must be in the form of `OWNER/REPOSITORY`, and must represent a GitHub-hosted, Gem-based Jekyll theme. See [the Jekyll documentation](https://jekyllrb.com/docs/themes/) for more information on authoring a Gem-based theme.

You may also optionally specify a branch, tag, or commit to use by appending an `@` and the Git ref (e.g., `benbalter/retlab@v1.0.0` or `benbalter/retlab@develop`).

## Requirements

Jekyll Remote Theme requires both `curl` and `unzip` to be available in your `PATH`.

## Debugging

If the download fails, the full output of the `curl` and `unzip` commands will be outputted to console. Adding `--verbose` to the `build` or `serve` command may provide additional information.
