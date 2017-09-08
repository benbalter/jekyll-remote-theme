require "jekyll"
require "jekyll-github-metadata"
require "webmock/rspec"
require "pathname"

require_relative "spec_helpers/env_helper"
require_relative "spec_helpers/integration_helper"
require_relative "spec_helpers/web_mock_helper"
require_relative "spec_helpers/stub_helper"
require_relative "spec_helpers/fixture_helper"

SPEC_DIR = Pathname.new(__dir__)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Limits the available syntax to the non-monkey patched syntax that is recommended.
  # For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = false

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  config.include WebMockHelper
  config.include StubHelper
  config.include IntegrationHelper
  config.include EnvHelper
  config.include FixtureHelper

  WebMock.enable!
  WebMock.disable_net_connect!

  config.before(:all) do
    FileUtils.mkdir_p("tmp")
  end

  config.before(:each) do
    Jekyll::GitHubMetadata.reset!
    Jekyll::GitHubMetadata.logger = Logger.new(StringIO.new) unless ENV["DEBUG"]
    ENV.delete("JEKYLL_ENV")
    ENV["PAGES_ENV"] = "test"
    ENV["PAGES_REPO_NWO"] = nil
  end
end
