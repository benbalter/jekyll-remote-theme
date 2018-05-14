# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class Downloader
      HOST = "https://codeload.github.com".freeze
      PROJECT_URL = "https://github.com/benbalter/jekyll-remote-theme".freeze
      TYPHOEUS_OPTIONS = {
        :headers => {
          :user_agent => "Jekyll Remote Theme/#{VERSION} (+#{PROJECT_URL})",
        },
        :verbose => (Jekyll.logger.level == :debug),
      }.freeze

      attr_reader :theme, :cache_duration, :skip_download
      private :theme, :cache_duration

      def initialize(theme, cache_duration = nil)
        @theme = theme
        @cache_duration = cache_duration
        @skip_download = false
      end

      def run
        if downloaded?
          Jekyll.logger.debug LOG_KEY, "Using existing #{theme.name_with_owner}"
          return
        end

        @zip_file = zip_file_path
        download
        unzip

        @downloaded = true
      end

      def downloaded?
        @downloaded ||= theme_dir_exists? && !theme_dir_empty?
      end

      private

      def use_cache?
        !@cache_duration.nil?
      end

      def zip_file_path
        return Tempfile.new([TEMP_PREFIX, ".zip"]) unless use_cache?

        cache_path = File.join(Dir.tmpdir, "#{TEMP_PREFIX}#{@theme.name}.zip")
        unless File.exist?(cache_path)
          FileUtils.touch(cache_path)
          return File.open(cache_path, "w")
        end

        cache_file = File.open(cache_path, "r")
        cache_age = Time.now - cache_file.ctime

        # Still fresh
        if cache_age < @cache_duration
          @skip_download = true
          return cache_file
        end

        # Too old, we delete and start anew
        FileUtils.rm(cache_path)
        FileUtils.touch(cache_path)
        File.open(cache_path, "w")
      end

      def download
        if @skip_download
          Jekyll.logger.debug LOG_KEY, "Using #{@zip_file.path} cache"
          return
        end

        Jekyll.logger.debug LOG_KEY, "Downloading #{zip_url} to #{@zip_file.path}"
        request = Typhoeus::Request.new zip_url, TYPHOEUS_OPTIONS
        request.on_headers  { |response| raise_if_unsuccessful(response) }
        request.on_body     { |chunk| @zip_file.write(chunk) }
        request.on_complete { |response| raise_if_unsuccessful(response) }
        request.run
      end

      def unzip
        Jekyll.logger.debug LOG_KEY, "Unzipping #{@zip_file.path} to #{theme.root}"

        # File IO is already open, rewind pointer to start of file to read
        @zip_file.rewind

        Zip::File.open(@zip_file) do |archive|
          archive.each { |file| file.extract path_without_name_and_ref(file.name) }
        end

        @zip_file.unlink unless use_cache?
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

      def raise_if_unsuccessful(response)
        if response.timed_out?
          raise DownloadError, "Request timed out"
        elsif response.code.zero?
          raise DownloadError, response.return_message
        elsif response.code != 200
          msg = "Request failed with #{response.code} - #{response.status_message}"
          raise DownloadError, msg
        end
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
