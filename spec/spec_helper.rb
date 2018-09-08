# frozen_string_literal: true

require_relative "../lib/jekyll-remote-theme"
require "fileutils"
require "open3"
require "pathname"
require "webmock/rspec"
WebMock.allow_net_connect!

RSpec.configure do |config|
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end
  config.order = :random
  Kernel.srand config.seed
end

RSpec::Matchers.define :be_an_existing_file do
  match { |path| File.exist?(path) }
end

def tmp_dir
  @tmp_dir ||= File.expand_path "../tmp", __dir__
end

def source_dir
  @source_dir ||= fixture_path "site"
end

def dest_dir
  @dest_dir ||= File.join tmp_dir, "dest"
end

def gemspec_dir(*contents)
  File.join(fixture_path("gemspecs"), *contents)
end

def reset_tmp_dir
  FileUtils.rm_rf tmp_dir
  FileUtils.mkdir_p tmp_dir
end

def fixture_path(fixture)
  File.expand_path "fixtures/#{fixture}", __dir__
end

def config_defaults
  {
    "source"      => source_dir,
    "destination" => dest_dir,
    "gems"        => ["jekyll-remote-theme"],
  }
end

def make_site(options = {})
  config = Jekyll.configuration config_defaults.merge(options)
  Jekyll::Site.new(config)
end
