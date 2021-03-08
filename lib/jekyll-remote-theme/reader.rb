# frozen_string_literal: true

require "csv"
module Jekyll
  module RemoteTheme
    class Reader < Jekyll::Reader
      def initialize(site)
        @site = site
        @theme = site.theme
      end

      def read
        super

        if @theme.data_path
          theme_data = ThemeDataReader.new(site).read(site.config["data_dir"])
          @site.data = Jekyll::Utils.deep_merge_hashes(theme_data, @site.data)
        end
      end
    end
  end
end
