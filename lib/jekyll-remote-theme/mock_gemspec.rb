# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    # Jekyll::Theme expects the theme's gemspec to tell it things like
    # the path to the theme and runtime dependencies. MockGemspec serves as a
    # stand in, since remote themes don't have Gemspecs
    class MockGemspec
      extend Forwardable
      def_delegator :theme, :root, :full_gem_path

      def initialize(theme)
        @theme = theme
      end

      def runtime_dependencies
        []
      end

      private

      attr_reader :theme
    end
  end
end
