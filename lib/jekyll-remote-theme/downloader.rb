# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class Downloader
      PROJECT_URL = "https://github.com/benbalter/jekyll-remote-theme"
      USER_AGENT = "Jekyll Remote Theme/#{VERSION} (+#{PROJECT_URL})"
      MAX_FILE_SIZE = 1 * (1024 * 1024 * 1024) # Size in bytes (1 GB)
      NET_HTTP_ERRORS = [
        Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::OpenTimeout,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
      ].freeze

      def initialize(theme, remote_headers)
        @theme = theme
        @remote_headers = remote_headers
      end

      def run
        if downloaded?
          Jekyll.logger.debug LOG_KEY, "Using existing #{theme.name_with_owner}"
          return
        end

        download
        unzip
      end

      def downloaded?
        @downloaded ||= theme_dir_exists? && !theme_dir_empty?
      end

      def remote_headers
        default_headers = {
          "User-Agent" => USER_AGENT,
          "Accept"     => "application/vnd.github.v3+json",
        }

        @remote_headers ||= default_headers
        @remote_headers.merge(default_headers)
      end

      private

      attr_reader :theme

      def zip_file
        @zip_file ||= Tempfile.new([TEMP_PREFIX, ".zip"], :binmode => true)
      end

      def create_request(url)
        req = Net::HTTP::Get.new url.path

        remote_headers&.each do |key, value|
          req[key] = value unless value.nil?
        end

        req
      end

      def handle_response(response)
        raise_unless_success(response)
        enforce_max_file_size(response.content_length)
        response.read_body do |chunk|
          zip_file.write chunk
        end
      end

      def fetch(uri_str, limit = 10)
        Jekyll.logger.debug LOG_KEY, "Finding redirect of #{uri_str}"

        raise DownloadError, "Too many redirect" if limit.zero?

        url = URI.parse(uri_str)
        req = create_request(url)

        Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
          http.request(req) do |response|
            case response
            when Net::HTTPSuccess
              handle_response(response)
            when Net::HTTPRedirection
              fetch(response["location"], limit - 1)
            else
              raise DownloadError, "#{response.code} - #{response.message}"
            end
          end
        end
      end

      def download
        Jekyll.logger.debug LOG_KEY, "Downloading #{zip_url} to #{zip_file.path}"
        fetch(zip_url)
        @downloaded = true
      rescue *NET_HTTP_ERRORS => e
        raise DownloadError, e.message
      end

      def raise_unless_success(response)
        return if response.is_a?(Net::HTTPSuccess)

        raise DownloadError, "#{response.code} - #{response.message}"
      end

      def enforce_max_file_size(size)
        return unless size && size > MAX_FILE_SIZE

        raise DownloadError, "Maximum file size of #{MAX_FILE_SIZE} bytes exceeded"
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
        @zip_url ||= Addressable::URI.new(
          :scheme => theme.scheme,
          :host   => theme.host,
          :path   => [theme.owner, theme.name, "archive", theme.git_ref + ".zip"].join("/")
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
