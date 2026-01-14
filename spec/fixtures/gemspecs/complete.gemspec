# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "complete"
  spec.version = "1.2.3"
  spec.authors = ["Jane Smith", "John Doe"]
  spec.email   = ["jane@example.com"]
  spec.summary = "A complete test gemspec"
  spec.description = "A longer description of the test theme"
  spec.homepage = "https://github.com/example/complete"
  spec.license = "MIT"

  spec.add_runtime_dependency "jekyll", "~> 4.0"
end
