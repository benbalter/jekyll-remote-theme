module Jekyll
  module RemoteTheme
    class Theme < Jekyll::Theme
      THEME_REGEX = %r!\A([a-z0-9\-_]+)(?:/([a-z0-9\-_]+)(?:@([a-z0-9]+))?)?\z!i
      GIT_HOST = "https://github.com".freeze

      # Initializes a new Jekyll::RemoteTheme::Theme
      #
      # raw_theme can be in the form of:
      #
      # 1. theme-name - a gem-based theme
      # 2. owner/theme-name - a GitHub owner + theme-name string
      # 3. owner/theme-name@git_ref - a GitHub owner + theme-name + Git ref string
      def initialize(raw_theme)
        @raw_theme = raw_theme.downcase.strip
        super(name)
      end

      def name
        theme_parts[2] || theme_parts[1]
      end

      def owner
        theme_parts[1] if theme_parts[2]
      end

      def name_with_owner
        [owner, name].join("/")
      end
      alias_method :nwo, :name_with_owner

      def valid?
        local? || remote?
      end

      def invalid?
        !valid?
      end

      def git_url
        "#{GIT_HOST}/#{owner}/#{name}" if remote?
      end

      def git_ref
        theme_parts[3] || "master" if remote?
      end

      def remote?
        !owner.nil? && !gem?
      end

      def local?
        owner.nil? && gem?
      end

      def inspect
        "#<Jekyll::RemoteTheme::Theme owner=\"#{owner}\" name=\"#{name}\">"
      end

      # Note: On OS X Dir.mktmpdir returns a symlink
      def root
        @root ||= File.realpath Dir.mktmpdir("jekyll-remote-theme-")
      end

      private

      def theme_parts
        @theme_parts ||= @raw_theme.match(THEME_REGEX)
      end

      def gem?
        return @gem if defined? @gem
        @gem = !Gem::Specification.find_by_name(name).nil?
      rescue Gem::LoadError
        @gem = false
      end

      def gemspec
        @gemspec ||= if gem?
                       Gem::Specification.find_by_name(name)
                     else
                       MockGemspec.new(self)
                     end
      end
    end
  end
end
