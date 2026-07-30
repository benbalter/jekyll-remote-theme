# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "jekyll-test-theme-malicious"
  spec.version       = "0.1.0"
  spec.authors       = ["Ben Balter"]
  spec.email         = ["benbalter@github.com"]

  spec.summary       = %q{A malicious theme for Jekyll (for testing).}
  spec.homepage      = "https://github.com/jekyll/jekyll-test-theme-malicious"
  spec.license       = "MIT"

  spec.metadata["plugin_type"] = "theme"

  spec.files         = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(assets|_(includes|layouts|sass)/|(LICENSE|README)((\.(txt|md|markdown)|$)))}i)
  end

  spec.add_runtime_dependency "jekyll", "~> 3.5"
  spec.add_runtime_dependency "jekyll-seo-tag", "~> 2.1"
  spec.add_runtime_dependency "jekyll_test_plugin_malicious", "~> 0.2"

  spec.add_development_dependency "bundler", "~> 1.12"
end
