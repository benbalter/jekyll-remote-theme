module Jekyll
  module RemoteTheme
    class Munger
      extend Forwardable
      def_delegator :site, :config
      attr_writer :cloner
      attr_reader :site

      def initialize(site)
        @site = site
      end

      def munge!
        return unless theme

        unless theme.remote?
          msg = "The theme `#{theme.name}` was requested, but exists locally. "
          msg << "The Gem-based theme will be used instead."
          Jekyll.logger.warn "Remote theme: ", msg
          return false
        end

        cloner.run
        configure_theme
        theme
      end

      private

      def theme
        return unless raw_theme && raw_theme.is_a?(String)
        @theme ||= Theme.new(raw_theme, theme_path)
      end

      def raw_theme
        config[CONFIG_KEY]
      end

      def theme_path
        @theme_path ||= File.expand_path "_theme", config["source"]
      end

      def cloner
        @cloner ||= Cloner.new(
          :git_url => theme.git_url,
          :git_ref => theme.git_ref,
          :path    => theme_path
        )
      end

      def theme_dir_exists?
        @theme_dir_exists ||= Dir.exist?(theme_path)
      end

      def configure_theme
        return unless theme
        site.config["theme"] = theme.name
        site.theme = theme
        site.theme.configure_sass
        site.send(:configure_include_paths)
      end
    end
  end
end
