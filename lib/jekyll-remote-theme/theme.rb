# frozen_string_literal: true
require 'uri'

module Jekyll
  module RemoteTheme
    class Theme < Jekyll::Theme
      # Initializes a new Jekyll::RemoteTheme::Theme
      #
      # raw_theme can be in the form of:
      #
      # 1. owner/theme-name - a GitHub owner + theme-name string
      # 2. owner/theme-name@git_ref - a GitHub owner + theme-name + Git ref string
      # 3. http[s]://github.<yourEnterprise>.com/owner/theme-name - An enterprise GitHub instance + a GitHub owner + a theme-name string
      # 4. http[s]://github.<yourEnterprise>.com/owner/theme-name@git_ref - An enterprise GitHub instance + a GitHub owner + a theme-name + Git ref string
      def initialize(raw_theme)
        @raw_theme = raw_theme.to_s.downcase.strip
        super(@raw_theme)
      end

      def name
        theme_parts[:name]
      end

      def owner
        theme_parts[:owner]
      end

      def host
        (theme_parts[:host] && theme_parts[:scheme]) ? "#{theme_parts[:scheme]}://codeload.#{theme_parts[:host]}" : "https://codeload.github.com"
      end

      def name_with_owner
        [owner, name].join("/")
      end
      alias_method :nwo, :name_with_owner

      def valid?
        theme_parts && name && owner
      end

      def git_ref
        theme_parts[:git_ref]
      end

      def root
        @root ||= File.realpath Dir.mktmpdir(TEMP_PREFIX)
      end

      def inspect
        "#<Jekyll::RemoteTheme::Theme host=\"#{host}\" owner=\"#{owner}\" name=\"#{name}\"" \
        " ref=\"#{git_ref}\" root=\"#{root}\">"
      end

      private

      def theme_parts
        uri = URI(@raw_theme)
        @theme_parts = {:scheme => uri.scheme, :host => uri.host}
        uri.path, @theme_parts[:git_ref] = (uri.path.include? "@") ? uri.path.split('@') : [uri.path, "master"]
        # Make this a valid uri path even if it's just Owner/Name URI will fail if we don't
        uri.path = "/#{uri.path}" unless uri.path[0] == '/'
        # Since a valid uri path is absolute (starts with /) the first element of this split will always be empty string
        @theme_parts[:owner], @theme_parts[:name] = uri.path.split('/')[1..-1]
        @theme_parts
      end

      def gemspec
        @gemspec ||= MockGemspec.new(self)
      end
    end
  end
end
