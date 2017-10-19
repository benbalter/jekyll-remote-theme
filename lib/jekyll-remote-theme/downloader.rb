module Jekyll
  module RemoteTheme
    class Downloader
      include RemoteTheme::Executor

      HOST = "https://codeload.github.com".freeze
      PROJECT_URL = "https://github.com/benbalter/jekyll-remote-theme".freeze
      USER_AGENT  = "Jekyll Remote Theme/#{VERSION} (+#{PROJECT_URL})".freeze
      TEMP_PREFIX = "jekyll-remote-theme-".freeze

      attr_reader :theme
      private :theme

      def initialize(theme)
        @theme = theme
      end

      def run
        if downloaded?
          Jekyll.logger.debug LOG_KEY, "Using existing #{theme.name_with_owner}"
          return
        end

        download
        unzip
        set_theme_root

        @downloaded = true
      end

      def downloaded?
        @downloaded ||= theme_dir_exists? && !theme_dir_empty?
      end

      def temp_dir
        @temp_dir ||= File.realpath Dir.mktmpdir(TEMP_PREFIX)
      end

      private

      def zip_file
        @zip_file ||= Tempfile.new([TEMP_PREFIX, ".zip"])
      end

      def download
        Jekyll.logger.debug LOG_KEY, "Downloading #{zip_url} to #{zip_file.path}"
        cmd = [
          *timeout_command, "curl", "--url", zip_url, "--output", zip_file.path,
          "--user-agent", USER_AGENT, "--fail", "--silent", "--show-error",
        ]
        run_command(*cmd)
      end

      def unzip
        Jekyll.logger.debug LOG_KEY, "Unzipping #{zip_file.path} to #{temp_dir}"
        cmd = [*timeout_command, "unzip", zip_file.path, "-d", temp_dir]
        run_command(*cmd)
        zip_file.unlink
      end

      # Codeload generated zip files contain a top level folder in the form of
      # THEME_NAME-GIT_REF/. While requests for Git repos are case incensitive,
      # the zip subfolder will respect the case in the repository's name, thus
      # making it impossible to predict the true path to the theme. In case we're
      # on a case-sensitive file system, set the theme's root to the true theme
      # directory, after we've extracted the zip and can determine its actual path.
      def set_theme_root
        theme.root = Dir["#{temp_dir}/*"].first
        Jekyll.logger.debug LOG_KEY, "Setting theme root to #{theme.root}"
      end

      # Full URL to codeload zip download endpoint for the given theme
      def zip_url
        [HOST, theme.owner, theme.name, "zip", theme.git_ref].join("/")
      end

      def theme_dir_exists?
        theme.root && Dir.exist?(theme.root)
      end

      def theme_dir_empty?
        Dir["#{theme.root}/*"].empty?
      end
    end
  end
end
