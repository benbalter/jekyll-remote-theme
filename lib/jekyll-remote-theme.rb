require "jekyll"
$LOAD_PATH.unshift(File.dirname(__FILE__))

module Jekyll
  module RemoteTheme
    autoload :VERSION, "jekyll-remote-theme/version"
    autoload :Theme,   "jekyll-remote-theme/theme"
    autoload :Cloner,  "jekyll-remote-theme/cloner"
    autoload :Munger,  "jekyll-remote-theme/munger"
    autoload :MockGemspec, "jekyll-remote-theme/mock_gemspec"

    CONFIG_KEY = "remote_theme".freeze

    def self.init(site)
      Munger.new(site).munge!
    end
  end
end

Jekyll::Hooks.register :site, :after_reset do |site|
  Jekyll::RemoteTheme.init(site)
end
