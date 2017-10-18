require "open3"

module Jekyll
  module RemoteTheme
    module Executor
      TIMEOUT = 3600
      TIMEOUT_COMMANDS = %w(timeout gtimeout).freeze

      def run_command(*cmds)
        Jekyll.logger.debug LOG_KEY, "Cloning with `#{cmds.join(" ")}"
        Open3.capture2e(*clone_command)
      end

      def timeout_command
        cmd = TIMEOUT_COMMANDS.find { |exe| executable_exists?(exe) }
        cmd ? [cmd, TIMEOUT.to_s].freeze : [].freeze
      end

      private

      def executable_exists?(executable)
        ENV["PATH"].split(File::PATH_SEPARATOR).any? do |dir|
          exe = File.join(dir, executable)
          File.executable?(exe) && !File.directory?(exe)
        end
      end
    end
  end
end
