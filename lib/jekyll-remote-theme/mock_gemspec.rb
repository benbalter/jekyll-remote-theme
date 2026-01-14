# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    # Jekyll::Theme expects the theme's gemspec to tell it things like
    # the path to the theme and runtime dependencies. MockGemspec serves as a
    # stand in, since remote themes don't need Gemspecs
    class MockGemspec
      extend Forwardable
      def_delegator :theme, :root, :full_gem_path

      DEPENDENCY_PREFIX = %r!^\s*[a-z]+\.add_(?:runtime_)?dependency!.freeze
      DEPENDENCY_REGEX = %r!#{DEPENDENCY_PREFIX}\(?\s*["']([a-z_-]+)["']!.freeze

      # Regex patterns for extracting gemspec metadata
      AUTHORS_REGEX = %r!^\s*[a-z_]+\.authors\s*=\s*\[(.*?)\]!m.freeze
      VERSION_REGEX = %r!^\s*[a-z_]+\.version\s*=\s*["']([^"']+)["']!.freeze
      SUMMARY_REGEX = %r!^\s*[a-z_]+\.summary\s*=\s*["'](.*?)["']!.freeze
      DESCRIPTION_REGEX = %r!^\s*[a-z_]+\.description\s*=\s*["'](.*?)["']!.freeze

      # Default version when gemspec is missing or version cannot be determined
      DEFAULT_VERSION = "0.0.0"

      def initialize(theme)
        @theme = theme
      end

      def runtime_dependencies
        @runtime_dependencies ||= dependency_names.map do |name|
          Gem::Dependency.new(name)
        end
      end

      # Returns an array of authors from the gemspec
      def authors
        @authors ||= begin
          return [] unless contents

          match = contents.match(AUTHORS_REGEX)
          return [] unless match

          # Extract author names from the array string
          match[1].scan(%r!["']([^"']+)["']!).flatten
        end
      end

      # Returns the version from the gemspec as a Gem::Version object
      # Note: This extracts literal version strings like "1.2.3" from the gemspec.
      # It cannot evaluate version constants like MyGem::VERSION.
      def version
        @version ||= begin
                       return Gem::Version.new(DEFAULT_VERSION) unless contents

                       match = contents.match(VERSION_REGEX)
                       return Gem::Version.new(DEFAULT_VERSION) unless match

                       # Extract the version string and convert to Gem::Version
                       Gem::Version.new(match[1])
                     rescue ArgumentError
                       # If the version string is invalid, return default
                       Gem::Version.new(DEFAULT_VERSION)
                     end
      end

      # Returns the summary from the gemspec
      def summary
        @summary ||= begin
          return "" unless contents

          match = contents.match(SUMMARY_REGEX)
          match ? match[1] : ""
        end
      end

      # Returns the description from the gemspec
      def description
        @description ||= begin
          return nil unless contents

          match = contents.match(DESCRIPTION_REGEX)
          match ? match[1] : nil
        end
      end

      # Returns metadata hash from the gemspec
      # Note: Metadata parsing is not currently implemented
      def metadata
        @metadata ||= {}
      end

      private

      def contents
        @contents ||= File.read(path, :encoding => "utf-8") if path
      end

      def path
        @path ||= potential_paths.find { |path| File.exist? path }
      end

      def potential_paths
        [theme.name, "jekyll-theme-#{theme.name}"].map do |filename|
          File.expand_path "#{filename}.gemspec", theme.root
        end
      end

      def dependency_names
        @dependency_names ||= if contents
                                contents.scan(DEPENDENCY_REGEX).flatten
                              else
                                []
                              end
      end

      attr_reader :theme
    end
  end
end
