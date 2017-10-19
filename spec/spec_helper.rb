require_relative "../lib/jekyll-remote-theme"
require "fileutils"
require "open3"
require 'pathname'

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

def tmp_dir
  @tmp_dir ||= File.expand_path "../tmp", __dir__
end

def source_dir
  @source_dir ||= File.join tmp_dir, "source"
end

def dest_dir
  @dest_dir ||= File.join tmp_dir, "dest"
end

def zip_file_path
  @zip_file ||= File.join tmp_dir, "theme.zip"
end

def write_source_dir
  reset_tmp_dir
  FileUtils.cp_r fixture_path("site"), source_dir
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

def git_command(*command)
  output, status = Open3.capture2e("git", *command)
  raise StandardError, output if status.exitstatus != 0
end

def start_server
  @pid = Process.spawn("bundle exec jekyll serve --source #{tmp_dir} --dest #{tmp_dir}/_site --quiet")
  sleep 5
end

def stop_server
  Process.kill "INT", @pid
end

RSpec::Matchers.define :be_an_existing_file do
  match { |path| File.exist?(path) }
end
