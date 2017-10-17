module Jekyll
  module RemoteTheme
    class Cloner
      class CloneError < StandardError; end
      include RemoteTheme::Executor

      FLAGS = [
        "--recurse-submodules",
        "--depth", "1",
        "--verbose",
      ].freeze

      attr_reader :git_url, :git_ref, :path

      # Initialize a cloner instance
      #
      # git_url - the remote clone location (string)
      # git_ref - the remote reference to check out in our working dir (string)
      # path    - the absolute path to a clone location on the local disk (string)
      def initialize(git_url: nil, git_ref: "master", path: nil)
        @git_url = git_url
        @git_ref = git_ref
        @path    = path
      end

      def run
        return false unless path
        msg = "Cloning #{git_url} into a temporary local directory"
        Jekyll.logger.info "Remote Theme: ", msg
        output, status = run_command(*clone_command)
        raise CloneError, output if status.exitstatus != 0
        @cloned = true
      end

      private

      def clone_command
        [
          *timeout_command,
          "git",
          "clone",
          *FLAGS,
          "--branch", git_ref,
          git_url,
          path,
        ].compact
      end

      def clone_dir_exists?
        Dir.exist? path
      end

      def cloned?
        @cloned ||= clone_dir_exists?
      end
    end
  end
end
