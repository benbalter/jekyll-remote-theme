# -*- encoding: utf-8 -*-
# stub: rubocop-performance 1.6.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rubocop-performance".freeze
  s.version = "1.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rubocop-hq/rubocop-performance/issues", "changelog_uri" => "https://github.com/rubocop-hq/rubocop-performance/blob/master/CHANGELOG.md", "documentation_uri" => "https://docs.rubocop.org/rubocop-performance/", "homepage_uri" => "https://docs.rubocop.org/rubocop-performance/", "source_code_uri" => "https://github.com/rubocop-hq/rubocop-performance/" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Bozhidar Batsov".freeze, "Jonas Arvidsson".freeze, "Yuji Nakayama".freeze]
  s.date = "2020-06-05"
  s.description = "A collection of RuboCop cops to check for performance optimizations\nin Ruby code.\n".freeze
  s.email = "rubocop@googlegroups.com".freeze
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.homepage = "https://github.com/rubocop-hq/rubocop-performance".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Automatic performance checking tool for Ruby code.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rubocop>.freeze, [">= 0.71.0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
end
