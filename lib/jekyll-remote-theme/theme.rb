# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class Theme < Jekyll::Theme
      DEFAULT_SCHEME = "https"
      DEFAULT_HOST = "github.com"
      ALPHANUMERIC_WITH_DASH_REGEX = %r![\w\-]+!i.freeze
      ALPHANUMERIC_WITH_DASH_DOT_REGEX = %r![\w\-\.]+!i.freeze
      OWNER_REGEX = %r!(?<owner>#{ALPHANUMERIC_WITH_DASH_REGEX})!i.freeze
      NAME_REGEX  = %r!(?<name>#{ALPHANUMERIC_WITH_DASH_DOT_REGEX})!i.freeze
      REF_REGEX   = %r!@(?<ref>#{ALPHANUMERIC_WITH_DASH_DOT_REGEX})!i.freeze
      THEME_REGEX = %r!\A/?#{OWNER_REGEX}/#{NAME_REGEX}(?:#{REF_REGEX})?\z!i.freeze

      # Initializes a new Jekyll::RemoteTheme::Theme
      #
      # here are the valid combinations for repository/remote_theme
      #
      #   [scheme://host/]owner/theme-name[@git_ref]
      #
      #   optional scheme://host
      #     scheme (default: https): Could be any scheme but generally should be http, https or git
      #     host (default: github.com): Could be any host
      #
      #   owner: Git repo owner
      #   theme-name: Git repo name
      #   optional @git_ref (default: master): Git Reference hash, tag or branch
      #
      # Header to pass to remote call
      #
      def initialize(repository, remote_theme)
        @repository = repository
        @remote_theme = remote_theme.to_s.downcase
        super(@remote_theme)
      end

      def name
        theme_parts[:name]
      end

      def owner
        theme_parts[:owner]
      end

      def host
        uri&.host
      end

      def scheme
        uri&.scheme
      end

      def name_with_owner
        [owner, name].join("/")
      end
      alias_method :nwo, :name_with_owner

      def valid?
        return false unless uri && theme_parts && name && owner

        host && valid_hosts.include?(host)
      end

      def git_ref
        theme_parts[:ref] || "master"
      end

      def root
        @root ||= File.realpath Dir.mktmpdir(TEMP_PREFIX)
      end

      def inspect
        "#<Jekyll::RemoteTheme::Theme host=\"#{host}\" owner=\"#{owner}\" name=\"#{name}\"" \
        " ref=\"#{git_ref}\" root=\"#{root}\">"
      end

      def to_s
        uri.to_s
      end

      private

      def default_host
        ENV["GITHUB_HOSTNAME"] || ENV["PAGES_GITHUB_HOSTNAME"] || DEFAULT_HOST
      end

      def uri
        return @uri if defined? @uri

        remote_theme_parsed = Addressable::URI.parse(@remote_theme)
        @uri =  if @repository
                  # Use the remote host as the uri and the remote theme as the path
                  repository_parsed = Addressable::URI.parse(@repository)
                  Addressable::URI.new(
                    :scheme => repository_parsed.scheme,
                    :host   => repository_parsed.host,
                    :path   => remote_theme_parsed.path
                  )
                elsif remote_theme_parsed.scheme && remote_theme_parsed.host
                  # Use the remote theme as the uri
                  remote_theme_parsed
                else
                  # Otherwise, make some assumptions, using remote theme as the path
                  Addressable::URI.new(
                    :scheme => DEFAULT_SCHEME,
                    :host   => default_host,
                    :path   => remote_theme_parsed.path
                  )
                end
      rescue Addressable::URI::InvalidURIError
        @uri = nil
      end

      def theme_parts
        @theme_parts ||= uri.path.match(THEME_REGEX) if uri
      end

      def gemspec
        @gemspec ||= MockGemspec.new(self)
      end

      def valid_hosts
        @valid_hosts ||= [
          host,
          default_host,
        ].compact.to_set
      end
    end
  end
end
