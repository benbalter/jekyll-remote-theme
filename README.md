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

## Caching remote themes

By default, remote themes are downloaded to a temporary directory and cleaned up after each build. To persist themes across builds and reduce bandwidth usage, you can enable caching in your `_config.yml`:

```yml
remote_theme_cache:
  enabled: true
```

This will cache downloaded themes in `vendor/cache/remote-themes` within your project directory. Each theme version (based on owner, repository name, and Git ref) is cached separately, so you can use different versions without conflicts.

### Custom cache location

You can specify a custom cache directory:

```yml
remote_theme_cache:
  enabled: true
  path: .cache/themes  # Relative to your site's source directory
```

### Benefits of caching

- **Faster builds**: Skip downloads when the theme is already cached
- **Reduced bandwidth**: Download themes only once per version
- **Offline development**: Use cached themes without internet access
- **Multiple projects**: Share cached themes across builds of the same project

### Cache management

- Cached themes are organized by `owner/name/git_ref` structure
- Different Git refs (tags, branches, commits) are cached separately
- To clear the cache, simply delete the cache directory
- The cache directory is automatically created when caching is enabled

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
