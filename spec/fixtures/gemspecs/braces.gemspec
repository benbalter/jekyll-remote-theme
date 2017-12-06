# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "braces/version"

Gem::Specification.new do |s|
  s.name    = "braces"
  s.version = Braces::VERSION
  s.authors = ["John Doe"]
  s.summary = "Dummy gemspec"

  # rubocop:disable Style/StringLiterals
  # runtime dependencies
  s.add_dependency('jekyll',         "~> 3.5")
  s.add_dependency('jekyll-feed',    "~> 0.6")
  s.add_dependency('jekyll-sitemap', "~> 1.5")

  # development dependencies
  s.add_dependency('bundler',       "~> 1.12")
  s.add_dependency('rake',          "~> 10.0")
  # rubocop:enable Style/StringLiterals
end
