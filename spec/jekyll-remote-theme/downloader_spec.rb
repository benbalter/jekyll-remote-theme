# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::Downloader do
  let(:nwo) { "pages-themes/primer" }
  let(:theme) { Jekyll::RemoteTheme::Theme.new(nwo) }
  subject { described_class.new(theme) }

  before { write_source_dir }

  it "knows it's not downloaded" do
    expect(subject.downloaded?).to be_falsy
  end

  it "creates a temp dir" do
    expect(Dir.exist?(subject.temp_dir)).to be_truthy
  end

  it "creates a zip file" do
    expect(subject.send(:zip_file)).to be_an_existing_file
  end

  it "knows the theme dir doesn't exist" do
    expect(subject.send(:theme_dir_exists?)).to be_falsy
  end

  context "downloading" do
    before { subject.run }
    after { FileUtils.rm_rf subject.temp_dir if Dir.exist?(subject.temp_dir) }

    it "knows it's downloaded" do
      expect(subject.downloaded?).to be_truthy
    end

    it "sets the theme root" do
      expect(theme.root).to eql("#{subject.temp_dir}/primer-master")
    end

    it "extracts the theme" do
      expect("#{theme.root}/_layouts/default.html").to be_an_existing_file
    end

    it "deletes the zip file" do
      expect(subject.send(:zip_file).path).to be_nil
    end

    it "knows the theme dir exists" do
      expect(subject.send(:theme_dir_exists?)).to be_truthy
    end

    it "knows the theme dir isn't empty" do
      expect(subject.send(:theme_dir_empty?)).to be_falsy
    end
  end
end
