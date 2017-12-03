# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    # Since parsing / evaluating a gemspec from third-party themes can lead to arbitrary
    # code execution, this class exists to read the given file and handle the contents
    # within.
    class GemspecManager
      SKIP_LINE_REGEX = %r!\A(?:\s*(?:#|\$|require)|\n)!
      DEPENDENCY_MATCHER = %r!add_[runtime_]*dependency!
      DEPENDENCY_CAPTURE_REGEX = %r!#{DEPENDENCY_MATCHER}\(?\s*(?<dependency>[^)#]+)\s*!
      EXTRACT_QUOTED_STRING_REGEX = %r!(["'])(.*?[^\\])\1!

      # Returns the trimmed contents of the provided gemspec file.
      attr_reader :spec_contents

      # Returns an array of dependencies, each entry being a sub-array containing the
      # gem-name and its required version information.
      attr_reader :spec_dependencies

      def initialize(gemspec)
        @gemspec = gemspec
        @spec_contents = []
        @spec_dependencies = []

        read
      end

      # Returns the object as a debug String.
      def inspect
        "#<Jekyll::RemoteTheme::GemspecManager @gemspec=#{@gemspec.inspect}>"
      end

      private

      # Reads the gemspec at the given path, line-by-line, ignoring lines
      # that are comments or require a Ruby file.
      #
      # Returns a trimmed version of the initial gemspec file.
      def read
        return unless File.exist?(@gemspec)
        File.read(@gemspec).each_line do |line|
          next if line =~ SKIP_LINE_REGEX
          @spec_dependencies << extract_dependency(line) if line =~ DEPENDENCY_MATCHER
          @spec_contents << line
        end
      end

      # Use regex to first capture required substring from current line, and then
      # copy contents of each quoted string in the captured substring into a separate
      # sub-array and normalizing the quotes at the same time.
      def extract_dependency(line)
        line.match(DEPENDENCY_CAPTURE_REGEX)["dependency"]
          .scan(EXTRACT_QUOTED_STRING_REGEX).transpose[1]
      end
    end
  end
end
