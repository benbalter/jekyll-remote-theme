# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class Downloader
      HOST = "https://codeload.github.com".freeze
      PROJECT_URL = "https://github.com/benbalter/jekyll-remote-theme".freeze
      MAX_FILE_SIZE = 1 * (1024 * 1024 * 1024) # Size in bytes (1 GB)
      OPTIONS = {
        "User-Agent"         => "Jekyll Remote Theme/#{VERSION} (+#{PROJECT_URL})",
        :redirect            => false,
        :content_length_proc => ->(size) { enforce_max_file_size!(size) },
        :progress_proc       => ->(size) { enforce_max_file_size!(size) },
      }.freeze

      class << self
        private def enforce_max_file_size!(size)
          if size && size > MAX_FILE_SIZE
            raise DownloadError, "Maximum file size of #{MAX_FILE_SIZE} bytes exceeded"
          end
        end
      end

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

        @downloaded = true
      end

      def downloaded?
        @downloaded ||= theme_dir_exists? && !theme_dir_empty?
      end

      private

      def zip_file
        @zip_file ||= Tempfile.new([TEMP_PREFIX, ".zip"], :binmode => true)
      end

      def download
        Jekyll.logger.debug LOG_KEY, "Downloading #{zip_url} to #{zip_file.path}"
        io = URI(zip_url).open(OPTIONS)
        IO.copy_stream io, zip_file
        OpenURI::Meta.init zip_file, io
        zip_file
      rescue OpenURI::HTTPError, URI::InvalidURIError, SocketError => e
        raise DownloadError, "Request failed with #{e.message}"
      ensure
        io.close  if io
        io.unlink if io && io.respond_to?(:unlink)
      end

      def unzip
        Jekyll.logger.debug LOG_KEY, "Unzipping #{zip_file.path} to #{theme.root}"

        # File IO is already open, rewind pointer to start of file to read
        zip_file.rewind

        Zip::File.open(zip_file) do |archive|
          archive.each { |file| file.extract path_without_name_and_ref(file.name) }
        end
      ensure
        zip_file.close
        zip_file.unlink
      end

      # Full URL to codeload zip download endpoint for the given theme
      def zip_url
        Addressable::URI.join(
          HOST, "#{theme.owner}/", "#{theme.name}/", "zip/", theme.git_ref
        ).normalize
      end

      def theme_dir_exists?
        theme.root && Dir.exist?(theme.root)
      end

      def theme_dir_empty?
        Dir["#{theme.root}/*"].empty?
      end

      # Codeload generated zip files contain a top level folder in the form of
      # THEME_NAME-GIT_REF/. While requests for Git repos are case insensitive,
      # the zip subfolder will respect the case in the repository's name, thus
      # making it impossible to predict the true path to the theme. In case we're
      # on a case-sensitive file system, strip the parent folder from all paths.
      def path_without_name_and_ref(path)
        Jekyll.sanitized_path theme.root, path.split("/").drop(1).join("/")
      end
    end
  end
end
