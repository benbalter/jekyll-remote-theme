# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class Theme < Jekyll::Theme
      OWNER_REGEX   = %r!(?<owner>[a-z0-9\-]+)!i.freeze
      NAME_REGEX    = %r!(?<name>[a-z0-9\._\-]+)!i.freeze
      REF_REGEX     = %r!@(?<ref>[a-z0-9\._\-]+)!i.freeze # May be a branch, tag, or commit
      VERSION_REGEX = %r!~>(?<version>[a-z0-9\._\-]+)!i.freeze # May be a semantic version
      THEME_REGEX   = %r!\A#{OWNER_REGEX}/#{NAME_REGEX}(?:#{REF_REGEX}|#{VERSION_REGEX})?\z!i.freeze

      # Initializes a new Jekyll::RemoteTheme::Theme
      #
      # raw_theme can be in the form of:
      #
      # 1. owner/theme-name - a GitHub owner + theme-name string
      # 2. owner/theme-name@git_ref - a GitHub owner + theme-name + Git ref string
      # 3. owner/theme-name~>version - a GitHub owner + theme-theme + pessimistic semver
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

      def name_with_owner
        [owner, name].join("/")
      end
      alias_method :nwo, :name_with_owner

      def valid?
        theme_parts && name && owner
      end

      def git_ref
        return @git_ref if @git_ref
        if theme_parts[:version]
          other_version = Semantic::Version.new theme_parts[:version]
          tags = Git.ls_remote("https://github.com/#{name_with_owner}")["tags"].keys
          version = tags.map do |tag|
            begin
              version = Semantic::Version.new tag.sub(/^v/, "")
              next version if version.satisfies? "~> #{theme_parts[:version]}"
            rescue ArgumentError
            end
          end.compact.sort.last.to_s
          if version and (tags.include?(version) or tags.include?(version ="v#{version}"))
            @git_ref = version
          else
            @git_ref = theme_parts[:version]
          end
        else
          @git_ref = theme_parts[:ref] || "master"
        end
      end

      def root
        @root ||= File.realpath Dir.mktmpdir(TEMP_PREFIX)
      end

      def inspect
        "#<Jekyll::RemoteTheme::Theme owner=\"#{owner}\" name=\"#{name}\"" \
        " ref=\"#{git_ref}\" root=\"#{root}\">"
      end

      private

      def theme_parts
        @theme_parts ||= @raw_theme.match(THEME_REGEX)
      end

      def gemspec
        @gemspec ||= MockGemspec.new(self)
      end
    end
  end
end
