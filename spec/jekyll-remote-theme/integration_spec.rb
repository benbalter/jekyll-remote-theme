# frozen_string_literal: true

RSpec.describe "Jekyll::RemoteTheme Integration" do
  let(:theme) { "pages-themes/primer" }
  let(:config_path) { File.join source_dir, "_config.yml" }
  let(:index_path) { File.join dest_dir, "index.html" }
  let(:index_contents) { File.read(index_path) }
  let(:stylesheet_path) { File.join dest_dir, "assets", "css", "style.css" }
  let(:args) do
    [
      "bundle", "exec", "jekyll", "build", "--config", config_path,
      "--source", source_dir, "--dest", dest_dir, "--verbose",
    ]
  end
  before { reset_tmp_dir }
  after { reset_tmp_dir }

  it "builds with the remote theme" do
    Dir.chdir tmp_dir do
      output, status = Open3.capture2e(*args)
      output = output.encode("UTF-8",
        :invalid => :replace, :undef => :replace, :replace => "")
      expect(status.exitstatus).to eql(0), output
      expect(output).to match("Remote Theme: Using theme pages-themes/primer")
      expect(index_path).to be_an_existing_file
      expected = '<div class="container-lg px-3 my-5 markdown-body">'
      expect(index_contents).to match(expected)

      expect(stylesheet_path).to be_an_existing_file
    end
  end
end
