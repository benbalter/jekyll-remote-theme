# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    # Since evaluating a gemspec from third-party themes can lead to arbitrary code
    # execution, this class safely reads a gemspec file at the root of given theme
    # and handles any runtime dependencies declared within.
    class DependencyManager
      DEPENDENCY_MATCHER = %r!add_(?:runtime_)?dependency!
      EXTRACT_DEPENDENCY_REGEX = %r!#{DEPENDENCY_MATCHER}(?:[(|\s])["'](.*?[^\\])["']!

      # Returns an array of dependency gem-names.
      attr_reader :theme_dependencies

      def initialize(theme, whitelist)
        @theme = theme
        @whitelist = whitelist
        @theme_dependencies = []
      end

      # Reads the gemspec at the given path, line-by-line, checking if the line
      # contains a dependency declaration.
      #
      # Returns nothing, but stores the match in an array which can be accessed by
      # calling +:theme_dependencies+
      def extract_dependencies
        return if @gemspec.nil? || !@theme_dependencies.empty?

        File.read(@gemspec).each_line do |line|
          next unless line =~ DEPENDENCY_MATCHER
          line.match(EXTRACT_DEPENDENCY_REGEX)
          @theme_dependencies << Regexp.last_match(1)
        end
      end

      # Traverse the array of dependencies and +require+ the dependency if its
      # whitelisted for current site.
      #
      # Returns nothing
      def require_dependencies
        theme_dependencies.each do |dependency|
          next if dependency == "jekyll"
          if @whitelist.include?(dependency)
            Jekyll::External.require_with_graceful_fail(dependency)
          end
        end
      end

      # Returns the object as a debug String.
      def inspect
        "#<Jekyll::RemoteTheme::DependencyManager " \
          "@gemspec=#{@gemspec.inspect} " \
          "@theme_dependencies=#{@theme_dependencies}>"
      end

      private

      def gemspec
        @gemspec ||=
          if File.exist?(nominal_gemspec)
            nominal_gemspec
          elsif !gemspec_files.empty?
            gemspec_files[0]
          end
      end

      # In the situation that the gemspec file(s) has not been named identical to the
      # repository name, store an array of `.gemspec` file(s) at the root.
      def gemspec_files
        @gemspec_files ||= Jekyll::Utils.safe_glob(@theme.root, "*.gemspec")
      end

      def nominal_gemspec
        @nominal_gemspec ||= File.expand_path(@theme.root, "#{theme.name}.gemspec")
      end
    end
  end
end
