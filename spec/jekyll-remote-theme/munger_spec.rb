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
    hooks = Jekyll::Hooks.instance_variable_get("@registry")
    hooks[:site][:after_reset] = []
    Jekyll::Hooks.instance_variable_set("@registry", hooks)
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
    after { Jekyll.instance_variable_set("@logger", @old_logger) }

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

    it "requires plugins" do
      @stubbed_logger.rewind
      expect(@stubbed_logger.read).to include("Requiring: jekyll-seo-tag")
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
    after { Jekyll.instance_variable_set("@logger", @old_logger) }

    it "sets the theme" do
      expect(site.theme).to be_a(Jekyll::RemoteTheme::Theme)
      expect(site.theme.name).to eql("jekyll-test-theme-malicious")
      expect(site.config["theme"]).to eql("jekyll-test-theme-malicious")
    end

    it "requires whitelisted plugins" do
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
end
