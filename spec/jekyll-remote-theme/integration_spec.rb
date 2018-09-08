# frozen_string_literal: true

RSpec.describe "Jekyll::RemoteTheme Integration" do
  attr_reader :output, :status

  def config_path
    File.join source_dir, "_config.yml"
  end

  def malicious_config_path
    File.join source_dir, "_malicious_config.yml"
  end

  def args(config_path)
    [
      "bundle", "exec", "jekyll", "build", "--config", config_path,
      "--source", source_dir, "--dest", dest_dir, "--verbose", "--safe",
    ]
  end

  def build_site(config_path)
    Dir.chdir tmp_dir do
      @output, @status = Open3.capture2e(*args(config_path))
      @output = @output.encode("UTF-8",
        :invalid => :replace, :undef => :replace, :replace => "")
    end
  end

  let(:theme) { "pages-themes/primer" }
  let(:index_path) { File.join dest_dir, "index.html" }
  let(:index_contents) { File.read(index_path) }
  let(:stylesheet_path) { File.join dest_dir, "assets", "css", "style.css" }

  context "the pages-themes/primer theme" do
    before(:all) { reset_tmp_dir }
    before(:all) { build_site(config_path) }
    after(:all) { reset_tmp_dir }

    it "returns a zero exit code" do
      expect(status.exitstatus).to eql(0), output
    end

    it "outputs that it's using a remote theme" do
      expect(output).to match("Remote Theme: Using theme #{theme}")
    end

    it "build the index" do
      expect(index_path).to be_an_existing_file
    end

    it "uses the theme" do
      expected = '<div class="container-lg px-3 my-5 markdown-body">'
      expect(index_contents).to match(expected)
    end

    it "builds stylesheets" do
      expect(stylesheet_path).to be_an_existing_file
    end

    it "requires dependencies" do
      expect(output).to include("Requiring: jekyll-seo-tag")
      expect(index_contents).to include("Begin Jekyll SEO tag")
    end
  end

  context "the jekyll/jekyll-test-theme-malicious theme" do
    let(:theme) { "jekyll/jekyll-test-theme-malicious" }
    before(:all) { reset_tmp_dir }
    before(:all) { build_site(malicious_config_path) }
    after(:all) { reset_tmp_dir }

    it "returns a zero exit code" do
      expect(status.exitstatus).to eql(0), output
    end

    it "outputs that it's using a remote theme" do
      expect(output).to match("Remote Theme: Using theme #{theme}")
    end

    it "build the index" do
      expect(index_path).to be_an_existing_file
    end

    it "uses the theme" do
      expect(index_contents).to include("Begin Jekyll SEO tag")
    end

    it "requires whitelisted dependencies" do
      expect(output).to include("Requiring: jekyll-seo-tag")
    end

    it "dosn't requires unsafe dependencies" do
      expect(output).to_not include("jekyll_test_plugin_malicious"), output
    end
  end
end
