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
        return unless theme_url # Return early if no valid theme URL

        unless theme.valid?
          Jekyll.logger.error LOG_KEY, "#{raw_theme.inspect} is not a valid remote theme"
          return
        end

        Jekyll.logger.info LOG_KEY, "Using theme #{theme.name_with_owner}"
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
        @theme ||= Theme.new(theme_url, :submodules => submodules?)
      end

      def raw_theme
        config[CONFIG_KEY]
      end

      def theme_url
        return raw_theme unless raw_theme.is_a?(Hash)

        raw_theme["url"] || raw_theme[:url]
      end

      def submodules?
        return config["submodules"] if raw_theme.is_a?(String)
        return false unless raw_theme.is_a?(Hash)

        raw_theme["submodules"] || raw_theme[:submodules] || false
      end

      def downloader
        @downloader ||= Downloader.new(theme)
      end

      def configure_theme
        return unless theme

        site.config["theme"] = theme.name
        site.theme = theme
        site.theme.configure_sass if site.theme.respond_to?(:configure_sass)
        site.send(:configure_include_paths)
        site.plugin_manager.require_theme_deps
        initialize_github_metadata
      end

      # Initialize GitHub metadata munger if it was loaded after :after_init hook
      def initialize_github_metadata
        return unless defined?(Jekyll::GitHubMetadata::SiteGitHubMunger)
        return if Jekyll::GitHubMetadata::SiteGitHubMunger.global_munger

        munger = Jekyll::GitHubMetadata::SiteGitHubMunger.new(site)
        munger.munge!
        Jekyll::GitHubMetadata::SiteGitHubMunger.global_munger = munger
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
