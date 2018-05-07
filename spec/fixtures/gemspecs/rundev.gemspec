# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rundev/version"

Gem::Specification.new do |spec|
  spec.name    = "rundev"
  spec.version = RunDev::VERSION
  spec.authors = ["John Doe"]
  spec.summary = "Dummy gemspec"

  spec.add_runtime_dependency "jekyll", "~> 3.5"
  spec.add_runtime_dependency "jekyll-feed", "~> 0.6" # some "random" comment
  spec.add_runtime_dependency "jekyll-sitemap", "~> 1.5"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
