# frozen_string_literal: true

path_to_cops = File.join(File.expand_path("rubocop", __dir__), "cop", "**", "*.rb")
Dir[path_to_cops].each { |cop| require cop }
