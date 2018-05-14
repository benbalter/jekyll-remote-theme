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

  s.add_dependency "jekyll", "~> 3.5"
  s.add_dependency "rubyzip", ">= 1.2.1", "< 3.0"
  s.add_development_dependency "jekyll-theme-primer", "~> 0.5"
  s.add_development_dependency "jekyll_test_plugin_malicious", "~> 0.2"
  s.add_development_dependency "pry", "~> 0.11"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rubocop", "~> 0.4", ">= 0.49.0"
  s.add_development_dependency "webmock", "~> 3.0"
end
