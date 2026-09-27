# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    # Net::HTTP setup shared by the theme download and the GitHub API lookup
    # for @latest, so both use the same proxy settings and timeouts.
    module HTTP
      OPEN_TIMEOUT = 10 # seconds
      READ_TIMEOUT = 60 # seconds
      PROXY_VARIABLES = {
        "https" => %w(https_proxy HTTPS_PROXY http_proxy HTTP_PROXY).freeze,
        "http"  => %w(http_proxy HTTP_PROXY).freeze,
      }.freeze

      module_function

      # Opens a connection to the host of `uri` (an Addressable::URI) and
      # yields the Net::HTTP session.
      def start(uri, use_ssl: uri.scheme == "https", env: ENV, &block)
        proxy = proxy_uri(uri, env)
        Net::HTTP.start(
          uri.host, uri.port,
          proxy&.host, proxy&.port, proxy&.user, proxy&.password,
          :use_ssl      => use_ssl,
          :open_timeout => OPEN_TIMEOUT,
          :read_timeout => READ_TIMEOUT,
          &block
        )
      end

      # The proxy to use for `uri`, from the environment. HTTPS requests use
      # https_proxy, falling back to http_proxy.
      def proxy_uri(uri, env = ENV)
        names = PROXY_VARIABLES.fetch(uri.scheme, PROXY_VARIABLES["http"])
        proxy = names.lazy.filter_map { |name| env[name] }.first
        Addressable::URI.parse(proxy) if proxy
      rescue Addressable::URI::InvalidURIError
        nil
      end
    end
  end
end
