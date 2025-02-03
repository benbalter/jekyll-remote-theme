# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "jekyll-remote-theme/version"

Gem::Specification.new do |s|
  s.name          = "jekyll-remote-theme"
  s.version       = Jekyll::RemoteTheme::VERSION
  s.authors       = ["Ben Balter"]
  s.email         = ["ben.balter@github.com"]
  s.homepage      = "https://github.com/benbalter/jekyll-remote-theme"
  s.summary       = "Jekyll plugin for building Jekyll sites with any GitHub-hosted theme"

  s.files         = `git ls-files app lib`.split("\n")
  s.require_paths = ["lib"]
  s.license       = "MIT"

  s.add_dependency "addressable", "~> 2.0"
  s.add_dependency "jekyll", ">= 3.5", "< 5.0"
  s.add_dependency "jekyll-sass-converter", ">= 1.0", "!= 2.0.0", "<= 4.0.0"
  s.add_dependency "rubyzip", ">= 1.3.0", "< 3.0"

  s.add_development_dependency "jekyll-theme-primer", "~> 0.5"
  s.add_development_dependency "jekyll_test_plugin_malicious", "~> 0.2"
  s.add_development_dependency "kramdown-parser-gfm", "~> 1.0"
  s.add_development_dependency "pry", "~> 0.11"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rubocop", "~> 0.71"
  s.add_development_dependency "rubocop-jekyll", "~> 0.10"
  s.add_development_dependency "webmock", "~> 3.0"
  s.required_ruby_version = ">= 2.3.0"
end
