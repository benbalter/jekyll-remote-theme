# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    # Net::HTTP setup shared by the theme download and the GitHub API lookup
    # for @latest, so both use the same proxy settings and timeouts.
    module HTTP
      OPEN_TIMEOUT = 10 # seconds
      READ_TIMEOUT = 60 # seconds
      # Proxy environment variables to try, by request scheme
      PROXY_SCHEMES = {
        "https" => %w(https http).freeze,
        "http"  => %w(http).freeze,
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

      # The proxy to use for `uri`, from the environment, or nil. HTTPS
      # requests use https_proxy, falling back to http_proxy. Hosts listed in
      # no_proxy/NO_PROXY, and loopback addresses, bypass the proxy.
      def proxy_uri(uri, env = ENV)
        PROXY_SCHEMES.fetch(uri.scheme, PROXY_SCHEMES["http"]).each do |scheme|
          target = URI::Generic.build(:scheme => scheme, :host => uri.host,
                                      :port   => uri.inferred_port)
          proxy = target.find_proxy(env)
          return proxy if proxy
        end
        nil
      rescue URI::Error
        nil
      end
    end
  end
end
