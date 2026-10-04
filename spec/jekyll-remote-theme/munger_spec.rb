# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::Munger do
  let(:source) { source_dir }
  let(:overrides) { {} }
  let(:config) { { "source" => source, "safe" => true }.merge(overrides) }
  let(:site) { make_site(config) }
  let(:theme_dir) { theme&.root }
  let(:layout_path) { File.expand_path "_layouts/default.html", theme_dir }
  let(:sass_dir) { File.expand_path "_sass/", theme_dir }
  let(:sass_path) { File.expand_path "jekyll-theme-primer.scss", sass_dir }
  let(:includes_dir) { File.expand_path "_includes/", theme_dir }
  let(:theme) { subject.send(:theme) }

  subject { described_class.new(site) }

  before { Jekyll.logger.log_level = :error }
  before { reset_tmp_dir }

  # Remove :after_reset hook to allow themes to be stubbed prior to munging
  before(:each) do
    hooks = Jekyll::Hooks.instance_variable_get(:@registry)
    hooks[:site][:after_reset] = []
    Jekyll::Hooks.instance_variable_set(:@registry, hooks)
  end

  it "stores the site" do
    expect(subject.site).to be_a(Jekyll::Site)
  end

  context "without a theme" do
    let(:source) { fixture_path("site-without-theme") }

    it "doesn't set a theme" do
      expect(site.theme).to_not be_a(Jekyll::RemoteTheme::Theme)
    end

    it "doesn't clone" do
      expect(layout_path).to_not be_an_existing_file
    end
  end

  context "with theme as a hash" do
    let(:overrides) { { "remote_theme" => { "foo" => "bar" } } }
    before { subject.munge! }

    it "doesn't set a theme" do
      expect(site.theme).to_not be_a(Jekyll::RemoteTheme::Theme)
    end

    it "doesn't clone" do
      expect(layout_path).to_not be_an_existing_file
    end
  end

  context "with a remote theme" do
    let(:overrides) { { "remote_theme" => "pages-themes/primer" } }
    before do
      @old_logger = Jekyll.logger
      @stubbed_logger = StringIO.new
      Jekyll.logger = Logger.new(@stubbed_logger)
      Jekyll.logger.log_level = :debug
    end
    before { subject.munge! }
    after { Jekyll.instance_variable_set(:@logger, @old_logger) }

    it "sets the theme" do
      expect(site.theme).to be_a(Jekyll::RemoteTheme::Theme)
      expect(site.theme.name).to eql("primer")
      expect(site.config["theme"]).to eql("primer")
    end

    it "downloads" do
      expect(layout_path).to be_an_existing_file
    end

    it "sets sass paths" do
      expect(sass_path).to be_an_existing_file

      if Jekyll::VERSION >= "4.0"
        converter = Jekyll::Converters::Scss.new(site.config)

        expect(converter.sass_configs[:load_paths]).to include(sass_dir)
      else
        expect(Sass.load_paths).to include(sass_dir)
      end
    end

    it "sets include paths" do
      expect(site.includes_load_paths).to include(includes_dir)
    end

    it "sets layouts" do
      site.read
      expect(site.layouts["default"]).to be_truthy
      expect(site.layouts["default"].path).to eql(layout_path)
    end

    context "when munging again on a rebuild" do
      let(:rebuild_munger) { described_class.new(site) }

      it "doesn't register another cleanup handler" do
        expect(rebuild_munger).not_to receive(:at_exit)
        rebuild_munger.munge!
      end

      it "doesn't create another temp directory" do
        expect(Dir).not_to receive(:mktmpdir)
        rebuild_munger.munge!
      end

      it "keeps the configured theme" do
        theme = site.theme
        rebuild_munger.munge!
        expect(site.theme).to equal(theme)
      end
    end

    it "requires plugins" do
      @stubbed_logger.rewind
      expect(@stubbed_logger.read).to include("Requiring: jekyll-seo-tag")
    end

    context "when GitHub metadata munger needs reinitialization" do
      before do
        # Simulate github-metadata being loaded
        unless defined?(Jekyll::GitHubMetadata)
          module Jekyll
            module GitHubMetadata
              class SiteGitHubMunger
                class << self
                  attr_accessor :global_munger
                end

                attr_reader :site

                def initialize(site)
                  @site = site
                end

                def munge!
                  # Mock implementation
                end
              end

              class << self
                attr_accessor :site
              end
            end
          end
        end
      end

      it "reinitializes munger when global_munger is nil" do
        # Ensure global_munger is nil
        Jekyll::GitHubMetadata::SiteGitHubMunger.global_munger = nil

        # Call initialize_github_metadata
        subject.send(:initialize_github_metadata)

        # Verify munger was initialized
        munger_class = Jekyll::GitHubMetadata::SiteGitHubMunger
        expect(munger_class.global_munger).to_not be_nil
        expect(munger_class.global_munger).to be_a(munger_class)
      end

      it "reinitializes munger when site instance differs" do
        # Create a munger for a different site
        other_site = make_site({ "source" => source_dir })
        other_munger = Jekyll::GitHubMetadata::SiteGitHubMunger.new(other_site)
        Jekyll::GitHubMetadata::SiteGitHubMunger.global_munger = other_munger
        Jekyll::GitHubMetadata.site = other_site

        # Call initialize_github_metadata with current site
        subject.send(:initialize_github_metadata)

        # Verify munger was reinitialized for current site
        expect(Jekyll::GitHubMetadata::SiteGitHubMunger.global_munger).to_not eq(other_munger)
      end

      it "does not reinitialize when munger is for current site" do
        # Create a munger for the current site
        current_munger = Jekyll::GitHubMetadata::SiteGitHubMunger.new(site)
        Jekyll::GitHubMetadata::SiteGitHubMunger.global_munger = current_munger
        Jekyll::GitHubMetadata.site = site

        # Call initialize_github_metadata
        subject.send(:initialize_github_metadata)

        # Verify munger was not replaced
        expect(Jekyll::GitHubMetadata::SiteGitHubMunger.global_munger).to eq(current_munger)
      end
    end
  end

  context "with a malicious theme" do
    let(:overrides) { { "remote_theme" => "jekyll/jekyll-test-theme-malicious" } }
    before do
      @old_logger = Jekyll.logger
      @stubbed_logger = StringIO.new
      Jekyll.logger = Logger.new(@stubbed_logger)
      Jekyll.logger.log_level = :debug
    end
    before { subject.munge! }
    after { Jekyll.instance_variable_set(:@logger, @old_logger) }

    it "sets the theme" do
      expect(site.theme).to be_a(Jekyll::RemoteTheme::Theme)
      expect(site.theme.name).to eql("jekyll-test-theme-malicious")
      expect(site.config["theme"]).to eql("jekyll-test-theme-malicious")
    end

    it "requires allowlisted plugins" do
      @stubbed_logger.rewind
      expect(@stubbed_logger.read).to include("Requiring: jekyll-seo-tag")
    end

    it "doesn't require malicious plugins" do
      @stubbed_logger.rewind
      expect(@stubbed_logger.read).to_not include("jekyll_test_plugin_malicious")
    end
  end

  context "with local layout override" do
    let(:source) { fixture_path("site-with-local-layouts") }
    let(:overrides) { { "remote_theme" => "pages-themes/primer" } }
    before { subject.munge! }

    it "uses local layout instead of theme layout" do
      site.read

      # Verify the local default layout is used
      expect(site.layouts["default"]).to be_truthy
      local_layout_path = File.join(source, "_layouts", "default.html")
      expect(site.layouts["default"].path).to eql(local_layout_path)

      # Verify content includes local layout marker
      content = File.read(site.layouts["default"].path)
      expect(content).to include("LOCAL LAYOUT")
      expect(content).to include("local-layout-marker")
    end

    it "uses theme layout when no local override exists" do
      site.read

      # Verify the theme's home layout is used (no local override)
      expect(site.layouts["home"]).to be_truthy
      expect(site.layouts["home"].path).to include(theme_dir)
      expect(site.layouts["home"].path).to_not include(source)
    end

    it "prioritizes local includes over theme includes" do
      # Verify local includes directory is first in the load paths
      expect(site.includes_load_paths.first).to eql(site.in_source_dir("_includes"))
    end
  end

  context "with a local theme path" do
    let(:workspace) { File.realpath(Dir.mktmpdir("jekyll-remote-theme-local-")) }
    let(:source) { File.join(workspace, "site") }
    let(:in_source_theme) { File.join(source, "_themes", "my-theme") }
    let(:sibling_theme) { File.join(workspace, "sibling-theme") }
    let(:safe) { false }
    let(:remote_theme) { "./_themes/my-theme" }
    let(:overrides) { { "safe" => safe, "remote_theme" => remote_theme } }

    def build_theme(dir)
      FileUtils.mkdir_p(File.join(dir, "_layouts"))
      File.write(File.join(dir, "_layouts", "default.html"), "layout content")
    end

    def log_output
      @stubbed_logger.rewind
      @stubbed_logger.read
    end

    before do
      [in_source_theme, sibling_theme].each { |dir| build_theme(dir) }
      @old_logger = Jekyll.logger
      @stubbed_logger = StringIO.new
      Jekyll.logger = Logger.new(@stubbed_logger)
      Jekyll.logger.log_level = :debug
      # Builds are typically run from the site directory
      @old_working_dir = Dir.pwd
      Dir.chdir(source)
    end

    after do
      Dir.chdir(@old_working_dir)
      Jekyll.instance_variable_set(:@logger, @old_logger)
      FileUtils.rm_rf(workspace)
    end

    shared_examples "an accepted local theme" do |theme_dir_method|
      it "sets the theme" do
        subject.munge!
        expected = send(theme_dir_method)
        expect(site.theme).to be_a(Jekyll::RemoteTheme::Theme)
        expect(site.theme.root).to eql(expected)
        expect(site.theme.layouts_path).to eql(File.join(expected, "_layouts"))
      end
    end

    shared_examples "a rejected local theme" do
      it "doesn't set the theme" do
        expect(subject.munge!).to be_nil
        expect(site.theme).to_not be_a(Jekyll::RemoteTheme::Theme)
      end

      it "logs an error" do
        subject.munge!
        expect(log_output).to include("is not a valid remote theme")
      end
    end

    context "outside safe mode" do
      context "with a path inside the site source" do
        it_behaves_like "an accepted local theme", :in_source_theme
      end

      context "with an absolute path outside the site source" do
        let(:remote_theme) { sibling_theme }

        it_behaves_like "an accepted local theme", :sibling_theme
      end

      context "with a ../ path to a sibling directory" do
        let(:remote_theme) { "../sibling-theme" }

        it_behaves_like "an accepted local theme", :sibling_theme
      end
    end

    context "in safe mode" do
      let(:safe) { true }

      context "with a path inside the site source" do
        it_behaves_like "a rejected local theme"
      end

      context "with an absolute path outside the site source" do
        let(:remote_theme) { sibling_theme }

        it_behaves_like "a rejected local theme"
      end

      context "with a ../ path to a sibling directory" do
        let(:remote_theme) { "../sibling-theme" }

        it_behaves_like "a rejected local theme"
      end
    end
  end
end
