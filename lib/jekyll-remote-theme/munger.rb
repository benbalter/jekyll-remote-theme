# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class Munger
      extend Forwardable
      def_delegator :site, :config
      attr_reader :site

      def initialize(site)
        @site = site
      end

      def munge!
        return unless remote_theme

        unless theme.valid?
          Jekyll.logger.error LOG_KEY, "#{theme} is not a valid remote theme"
          return
        end

        Jekyll.logger.info LOG_KEY, "Using theme #{theme}"
        unless munged?
          downloader.run
          configure_theme
        end
        enqueue_theme_cleanup

        theme
      end

      private

      def munged?
        site.theme&.is_a?(Jekyll::RemoteTheme::Theme)
      end

      def theme
        @theme ||= Theme.new(repository, remote_theme)
      end

      def remote_theme
        config[CONFIG_THEME_KEY]
      end

      def remote_header
        config[CONFIG_HEADERS_KEY]
      end

      def repository
        config[CONFIG_REPOSITORY_KEY]
      end

      def downloader
        @downloader ||= Downloader.new(theme, remote_header)
      end

      def setup_site_config
        site.config["theme"] = theme.name
        site.config["repository"] = "#{theme.scheme}://#{theme.host}"
      end

      def configure_theme
        return unless theme

        setup_site_config

        site.theme = theme
        site.theme.configure_sass if site.theme.respond_to?(:configure_sass)
        site.send(:configure_include_paths)
        site.plugin_manager.require_theme_deps
      end

      def enqueue_theme_cleanup
        at_exit do
          Jekyll.logger.debug LOG_KEY, "Cleaning up #{theme.root}"
          FileUtils.rm_rf theme.root
        end
      end
    end
  end
end
