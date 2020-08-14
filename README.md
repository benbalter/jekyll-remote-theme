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
   or
   ```yml
   remote_theme: https://github.<Enterprise>.com/benbalter/retlab
   ```
   or
   ```yml
   remote_host: https://github.<Enterprise>.com
   remote_theme: benbalter/retlab
   ```


## Declaring your theme

Remote themes are specified by the `remote_theme` key in the site's config.  By default, this will use `https://github.com` as the host.  If you would like to specify your own host, either specify the host part of the `remote_theme` (e.g., `https://github.com/benbalter/retlab`) or by specifying `remote_host` (e.g., `https://github.com`).

For GitHub, remote themes must be in the form of `OWNER/REPOSITORY`, and must represent a Jekyll theme. See [the Jekyll documentation](https://jekyllrb.com/docs/themes/) for more information on authoring a theme. Note that you do not need to upload the gem to RubyGems or include a `.gemspec` file.

You may also optionally specify a branch, tag, or commit to use by appending an `@` and the Git ref (e.g., `benbalter/retlab@v1.0.0` or `benbalter/retlab@develop`). If you don't specify a Git ref, the `master` branch will be used.

To use your own host, such as for Enterprise GitHub, you can specify `remote_theme` providing the full url (e.g., `https://GITHUBHOST.com/OWNER/REPOSITORY`), and must represent GitHub-hosted Jekyll theme. Alternatively, you can specify `remote_host`.  This works exactly the same as the GitHub usage.

## Private and Internal Themes

If you would like to use a private or internal hosted theme (or have other specific headers needs):

1. Create a Personal Access Token following the [Creating a personal access token on GitHub guides](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token)

2. Add the `remote_header` in your `_config.yml`

   ```yml
   remote_header: 
     Authorization: token <personal autorization token>
   ```
   Where the personal autorization token is the token  provided by the github repo setting page.

   > :warning: **Storing credentials can lead to security issues** - As stated in the [Creating a personal access   token on GitHub guides](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) Treat your tokens like passwords and keep them secret. When working with the API, use tokens as environment variables instead of hardcoding them into your programs.

## Debugging

Adding `--verbose` to the `build` or `serve` command may provide additional information.
