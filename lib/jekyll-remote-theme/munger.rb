# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class Munger
      extend Forwardable
      def_delegators Jekyll::RemoteTheme, :config, :site

      def initialize(site)
        Jekyll::RemoteTheme.site = site # Backwards compatability
      end

      def munge!
        return unless raw_theme

        unless theme.valid?
          Jekyll.logger.error LOG_KEY, "#{raw_theme.inspect} is not a valid remote theme"
          return
        end

        Jekyll.logger.info LOG_KEY, "Using theme #{theme.name_with_owner}"
        return theme if munged?

        downloader.run
        configure_theme
        enqueue_theme_cleanup

        theme
      end

      private

      def munged?
        site.theme&.is_a?(Jekyll::RemoteTheme::Theme)
      end

      def theme
        @theme ||= Theme.new(raw_theme)
      end

      def raw_theme
        if config.is_a?(String)
          config
        elsif config.is_a?(Hash)
          config["theme"]
        end
      end

      def downloader
        @downloader ||= Downloader.new(theme)
      end

      def configure_theme
        return unless theme

        site.config["theme"] = theme.name
        site.theme = theme
        site.theme.configure_sass
        site.send(:configure_include_paths)
        site.plugin_manager.require_theme_deps
      end

      def enqueue_theme_cleanup
        at_exit do
          next unless munged? && downloader.downloaded? && downloader.cache_expired?

          Jekyll.logger.debug LOG_KEY, "Cleaning up #{theme.root}"
          FileUtils.rm_rf theme.root
        end
      end
    end
  end
end
