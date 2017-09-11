require "open3"

module Jekyll
  module RemoteTheme
    class Cloner
      class CloneError < StandardError; end

      FLAGS = [
        "--recurse-submodules",
        "--depth", "1",
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

        if clone_dir_exists?
          msg = "_theme directory already exists in site source. "
          msg << "Not cloning remote theme."
          Jekyll.logger.warn "Remote theme: ", msg
          return false
        end

        Jekyll.logger.info "Remote theme: ", "Cloning into #{path}"
        output, status = Open3.capture2e(*clone_command)
        raise CloneError, output if status.exitstatus != 0
        @cloned = true
      end

      private

      def clone_command
        [
          "git",
          "clone",
          *FLAGS,
          "--branch", git_ref,
          "--verbose",
          git_url,
          path,
        ].compact
      end

      def cloned?
        @cloned ||= clone_dir_exists?
      end

      def clone_dir_exists?
        path && Dir.exist?(path)
      end
    end
  end
end
