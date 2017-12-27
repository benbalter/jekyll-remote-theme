# frozen_string_literal: true

RSpec.describe "Jekyll::RemoteTheme Integration" do
  attr_reader :output, :status

  def config_path
    File.join source_dir, "_config.yml"
  end

  def args
    [
      "bundle", "exec", "jekyll", "build", "--config", config_path,
      "--source", source_dir, "--dest", dest_dir, "--verbose",
    ]
  end

  let(:theme) { "pages-themes/primer" }
  let(:index_path) { File.join dest_dir, "index.html" }
  let(:index_contents) { File.read(index_path) }
  let(:stylesheet_path) { File.join dest_dir, "assets", "css", "style.css" }

  before(:all) { reset_tmp_dir }
  before(:all) do
    Dir.chdir tmp_dir do
      @output, @status = Open3.capture2e(*args)
      @output = @output.encode("UTF-8",
        :invalid => :replace, :undef => :replace, :replace => "")
    end
  end
  after(:all) { reset_tmp_dir }

  it "returns a zero exit code" do
    expect(status.exitstatus).to eql(0), output
  end

  it "outputs that it's using a remote theme" do
    expect(output).to match("Remote Theme: Using theme pages-themes/primer")
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
