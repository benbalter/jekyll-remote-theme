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
        @theme ||= Theme.new(raw_theme)
      end

      def raw_theme
        config[CONFIG_KEY]
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
      # or if the existing munger needs to be updated for the current site
      def initialize_github_metadata
        return unless defined?(Jekyll::GitHubMetadata::SiteGitHubMunger)
        
        # Create a new munger if one doesn't exist or if it's for a different site
        current_munger = Jekyll::GitHubMetadata::SiteGitHubMunger.global_munger
        needs_init = current_munger.nil? || (Jekyll::GitHubMetadata.respond_to?(:site) && Jekyll::GitHubMetadata.site != site)
        
        if needs_init
          Jekyll.logger.debug LOG_KEY, "Initializing GitHub metadata munger"
          munger = Jekyll::GitHubMetadata::SiteGitHubMunger.new(site)
          munger.munge!
          Jekyll::GitHubMetadata::SiteGitHubMunger.global_munger = munger
        end
      end

      def enqueue_theme_cleanup
        return if theme.local_theme? # Don't clean up local theme directories

        at_exit do
          Jekyll.logger.debug LOG_KEY, "Cleaning up #{theme.root}"
          FileUtils.rm_rf theme.root
        end
      end
    end
  end
end
