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
          Jekyll.logger.warn LOG_KEY, msg
          return false
        end

        Jekyll.logger.info LOG_KEY, "Using theme #{theme.name_with_owner}"

        return if munged?

        cloner.run
        configure_theme
        enqueue_theme_cleanup
        theme
      end

      private

      def munged?
        site.theme && site.theme.is_a?(Jekyll::RemoteTheme::Theme)
      end

      def theme
        return unless raw_theme && raw_theme.is_a?(String)
        @theme ||= Theme.new(raw_theme)
      end

      def raw_theme
        config[CONFIG_KEY]
      end

      def cloner
        @cloner ||= Cloner.new(
          :git_url => theme.git_url,
          :git_ref => theme.git_ref,
          :path    => theme.root
        )
      end

      def configure_theme
        return unless theme
        site.config["theme"] = theme.name
        site.theme = theme
        site.theme.configure_sass
        site.send(:configure_include_paths)
      end

      def enqueue_theme_cleanup
        at_exit do
          return unless munged? && cloner.cloned?
          Jekyll.logger.info LOG_KEY, "Cleaning up #{theme.name_with_owner}"
          FileUtils.rm_rf theme.root
        end
      end
    end
  end
end
