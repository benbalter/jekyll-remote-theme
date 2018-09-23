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
        site.theme && site.theme.is_a?(Jekyll::RemoteTheme::Theme)
      end

      def theme
        @theme ||=
          if cache_enabled?
            Theme.new(raw_theme, cache_dir: cache_dir)
          else
            Theme.new(raw_theme)
          end
      end

      def raw_theme
        config[CONFIG_KEY]
      end

      def cache_enabled?
        if @cache_enabled.nil?
          @cache_enabled = config[CONFIG_CACHE_ENABLED_KEY] == true
        end
        @cache_enabled
      end

      def cache_dir
        @cache_dir ||= File.expand_path(config[CONFIG_CACHE_DIR_KEY] || DEFAULT_CACHE_DIR)
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
          return unless !cache_enabled? && munged? && downloader.downloaded?
          Jekyll.logger.debug LOG_KEY, "Cleaning up #{theme.root}"
          FileUtils.rm_rf theme.root
        end
      end
    end
  end
end
