# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class Theme < Jekyll::Theme
      SAFE_REGEX = %r!^[a-z0-9\._\-]+$!i.freeze
      REF_REGEX = %r!@(?<ref>[a-z0-9\._\-]+)!i.freeze

      # Initializes a new Jekyll::RemoteTheme::Theme
      #
      # raw_theme can be in the form of:
      #
      # 1. http[s]://github.com/owner/theme-name[@git_ref]
      #    a GitHub owner + theme-name string + Optional Git Ref
      # 2. http[s]://github.<yourEnterprise>.com/owner/theme-name[@git_ref]
      #    An enterprise GitHub instance + a GitHub owner + a theme-name + Optional Git ref string
      #
      def initialize(raw_theme, auth)
        @raw_theme = raw_theme.to_s.downcase.strip
        @auth = auth
        super(@raw_theme)
      end

      attr_reader :auth

      def path
        tmp = uri&.path
        tmp[1..-1]
      end

      def name
        tmp = path
        tmp &&= tmp.split("/")[-1]
        tmp &&= tmp.split("@")[0]
        tmp &&= tmp.strip
        tmp
      end

      def owner
        tmp = path
        tmp &&= tmp.split("/")[-2]
        tmp &&= tmp.strip
        tmp
      end

      def host
        uri&.host || "github.com"
      end

      def scheme
        uri&.scheme || "https"
      end

      def name_with_owner
        [owner, name].join("/")
      end
      alias_method :nwo, :name_with_owner

      def valid?
        !!(SAFE_REGEX.match(host) &&
          SAFE_REGEX.match(scheme) &&
          SAFE_REGEX.match(name) &&
          SAFE_REGEX.match(git_ref) &&
          SAFE_REGEX.match(owner))
      end

      def git_ref
        tmp = path.split("@")[1] || "master"
        tmp.strip
      end

      def root
        @root ||= File.realpath Dir.mktmpdir(TEMP_PREFIX)
      end

      def inspect
        "#<Jekyll::RemoteTheme::Theme scheme=\"#{scheme}\" host=\"#{host}\"" \
        " owner=\"#{owner}\" name=\"#{name}\" ref=\"#{git_ref}\" root=\"#{root}\"" \
        "url=\"#{uri}\">"
      end

      private

      def uri
        return @uri if defined? @uri

        @uri = Addressable::URI.parse(@raw_theme)
      rescue Addressable::URI::InvalidURIError
        @uri = nil
      end

      def gemspec
        @gemspec ||= MockGemspec.new(self)
      end
    end
  end
end
