# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nodeps/version"

Gem::Specification.new do |s|
  s.name    = "nodeps"
  s.version = Lorem::VERSION
  s.authors = ["John Doe"]
  s.summary = "Dummy gemspec"

  s.add_development_dependency("bundler", "~> 1.12")
  s.add_development_dependency("rake",    "~> 10.0")
end
