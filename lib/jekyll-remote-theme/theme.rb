# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class Theme < Jekyll::Theme
      OWNER_REGEX = %r!(?<owner>[a-z0-9\-]+)!i.freeze
      NAME_REGEX  = %r!(?<name>[a-z0-9\._\-]+)!i.freeze
      REF_REGEX   = %r!@(?<ref>[a-z0-9\._\-]+)!i.freeze # May be a branch, tag, or commit
      THEME_REGEX = %r!\A#{OWNER_REGEX}/#{NAME_REGEX}(?:#{REF_REGEX})?\z!i.freeze

      # Initializes a new Jekyll::RemoteTheme::Theme
      #
      # raw_theme can be in the form of:
      #
      # 1. owner/theme-name - a GitHub owner + theme-name string
      # 2. owner/theme-name@git_ref - a GitHub owner + theme-name + Git ref string
      # 3. http[s]://github.<yourEnterprise>.com/owner/theme-name
      # - An enterprise GitHub instance + a GitHub owner + a theme-name string
      # 4. http[s]://github.<yourEnterprise>.com/owner/theme-name@git_ref
      # - An enterprise GitHub instance + a GitHub owner + a theme-name + Git ref string
      # 5. /absolute/path/to/theme - an absolute local file path
      # 6. ../relative/path/to/theme - a relative local file path
      # 7. ~/path/to/theme - a home directory relative path
      def initialize(raw_theme)
        original_theme = raw_theme.to_s.strip
        @raw_theme = looks_like_local_path?(original_theme) ? original_theme : original_theme.downcase
        super(@raw_theme)
      end

      def name
        return File.basename(expanded_local_path) if local_theme?

        theme_parts[:name]
      end

      def owner
        return "local" if local_theme?

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
        return local_path_valid? if local_theme?
        return false unless uri && theme_parts && name && owner

        host && valid_hosts.include?(host)
      end

      def git_ref
        theme_parts[:ref] || "HEAD"
      end

      def root
        return @root if defined?(@root) && @root

        @root = local_theme? ? expanded_local_path : File.realpath(Dir.mktmpdir(TEMP_PREFIX))
      end

      def inspect
        "#<Jekyll::RemoteTheme::Theme host=\"#{host}\" owner=\"#{owner}\" name=\"#{name}\"" \
        " ref=\"#{git_ref}\" root=\"#{root}\">"
      end

      def local_theme?
        looks_like_local_path?(@raw_theme)
      end

      private

      def looks_like_local_path?(path)
        # Check if it looks like a local path
        # Supports: /, ./, ../, ~/ (Unix-style) and drive letters (Windows-style)
        return true if path.start_with?("/", "./", "../", "~/")
        # Check for Windows-style absolute paths (e.g., C:\path or C:/path)
        return true if path.match?(%r{\A[a-z]:[/\\]}i)

        false
      end

      def expanded_local_path
        @expanded_local_path ||= File.expand_path(@raw_theme)
      end

      def local_path_valid?
        Dir.exist?(expanded_local_path)
      end

      def uri
        return @uri if defined? @uri
        return @uri = nil if local_theme?

        @uri = if THEME_REGEX.match?(@raw_theme)
                 Addressable::URI.new(
                   :scheme => "https",
                   :host   => "github.com",
                   :path   => @raw_theme
                 )
               else
                 Addressable::URI.parse @raw_theme
               end
      rescue Addressable::URI::InvalidURIError
        @uri = nil
      end

      def theme_parts
        return nil if local_theme?

        @theme_parts ||= uri.path[1..-1].match(THEME_REGEX) if uri
      end

      def gemspec
        @gemspec ||= MockGemspec.new(self)
      end

      def valid_hosts
        @valid_hosts ||= [
          "github.com",
          ENV["PAGES_GITHUB_HOSTNAME"],
          ENV["GITHUB_HOSTNAME"],
        ].compact.to_set
      end
    end
  end
end
