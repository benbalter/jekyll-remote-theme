# Jekyll Remote Theme

Jekyll plugin for building Jekyll sites with any public GitHub-hosted theme

[![Gem Version](https://badge.fury.io/rb/jekyll-remote-theme.svg)](https://badge.fury.io/rb/jekyll-remote-theme) [![CI](https://github.com/benbalter/jekyll-remote-theme/workflows/CI/badge.svg)](https://github.com/benbalter/jekyll-remote-theme/actions?query=workflow%3ACI) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)


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

  To use a specific release or branch:

  ```yml
  remote_theme: benbalter/retlab@v1.0.0
  ```

  To automatically use the latest tagged release:

  ```yml
  remote_theme: benbalter/retlab@latest
  ```

or <sup>1</sup>
  ```yml
  remote_theme: http[s]://github.<Enterprise>.com/benbalter/retlab
  ```
<sup>1</sup> The codeload subdomain needs to be available on your github enterprise instance for this to work.

## Declaring your theme

Remote themes are specified by the `remote_theme` key in the site's config.

For public GitHub, remote themes must be in the form of `OWNER/REPOSITORY`, and must represent a public GitHub-hosted Jekyll theme. See [the Jekyll documentation](https://jekyllrb.com/docs/themes/) for more information on authoring a theme. Note that you do not need to upload the gem to RubyGems or include a `.gemspec` file.

You may also optionally specify a branch, tag, or commit to use by appending an `@` and the Git ref (e.g., `benbalter/retlab@v1.0.0` or `benbalter/retlab@develop`). If you don't specify a Git ref, the `HEAD` ref will be used.

To automatically use the latest tagged release, you can specify `@latest` (e.g., `benbalter/retlab@latest`). This will fetch the most recent release from the GitHub Releases API. If no releases exist, it will fall back to using `HEAD`.

For Enterprise GitHub, remote themes must be in the form of `http[s]://GITHUBHOST.com/OWNER/REPOSITORY`, and must represent a public (non-private repository) GitHub-hosted Jekyll theme. Other than requiring the fully qualified domain name of the enterprise GitHub instance, this works exactly the same as the public usage.

### Using themes with Git submodules

If your remote theme includes Git submodules, you can enable submodule support by using either of the following configurations:

**Option 1: Using a separate `submodules` key:**

```yml
remote_theme: owner/repo
submodules: true
```

**Option 2: Using hash syntax:**

```yml
remote_theme:
  url: owner/repo
  submodules: true
```

When `submodules` is enabled, the theme will be cloned using `git clone --recurse-submodules` instead of downloading a ZIP archive. This ensures that all submodules are properly initialized and checked out.

**Note:** Enabling submodules requires Git to be available on your system and may take longer to download depending on the size and number of submodules.
## Customizing your theme

You can override any file from the remote theme by creating a file with the same path in your Jekyll site. This works for:

* **Layouts** (`_layouts/`) - Create a file with the same name in your `_layouts` directory to override a theme layout
* **Includes** (`_includes/`) - Create a file with the same name in your `_includes` directory to override a theme include
* **Sass files** (`_sass/`) - Add custom Sass files in your `_sass` directory
* **Assets** (`assets/`) - Override or add assets in your `assets` directory

### Example

If your remote theme has a `_layouts/default.html` file, you can override it by creating your own `_layouts/default.html` file in your site. Your local version will be used instead of the theme's version.

Similarly, if the theme has an `_includes/header.html` file, you can override it by creating `_includes/header.html` in your site.

**Note**: Only the specific files you override will use your local versions. All other theme files will continue to work as provided by the theme.

## Debugging

Adding `--verbose` to the `build` or `serve` command may provide additional information.
