# -*- encoding: utf-8 -*-
# stub: rubocop-jekyll 0.11.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rubocop-jekyll".freeze
  s.version = "0.11.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ashwin Maroli".freeze]
  s.date = "2020-03-19"
  s.description = "A RuboCop extension to enforce common code style in Jekyll and Jekyll plugins".freeze
  s.email = ["ashmaroli@gmail.com".freeze]
  s.homepage = "https://github.com/jekyll/rubocop-jekyll".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Code style check for Jekyll and Jekyll plugins".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rubocop>.freeze, [">= 0.68.0", "< 0.81.0"])
  s.add_runtime_dependency(%q<rubocop-performance>.freeze, ["~> 1.2"])
end
