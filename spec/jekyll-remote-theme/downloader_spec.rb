# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::Downloader do
  let(:raw_theme) { "pages-themes/primer" }
  let(:theme) { Jekyll::RemoteTheme::Theme.new(raw_theme) }
  subject { described_class.new(theme) }

  before { reset_tmp_dir }

  it "knows it's not downloaded" do
    expect(subject.downloaded?).to be_falsy
  end

  it "creates a zip file" do
    expect(subject.send(:zip_file)).to be_an_existing_file
  end

  context "downloading" do
    before { subject.run }
    after { FileUtils.rm_rf theme.root if Dir.exist?(theme.root) }

    it "knows it's downloaded" do
      expect(subject.downloaded?).to be_truthy
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

  context "zip_url" do
    it "builds the zip url" do
      expected = "https://codeload.github.com/pages-themes/primer/zip/HEAD"
      expect(subject.send(:zip_url).to_s).to eql(expected)
    end

    context "a custom host" do
      let(:raw_theme) { "http://example.com/pages-themes/primer" }

      it "builds the zip url" do
        expected = "http://codeload.example.com/pages-themes/primer/zip/HEAD"
        expect(subject.send(:zip_url).to_s).to eql(expected)
      end
    end
  end

  context "with zip_url stubbed" do
    before { allow(subject).to receive(:zip_url) { Addressable::URI.parse zip_url } }

    context "with an invalid URL" do
      let(:zip_url) { "https://codeload.github.com/benbalter/_invalid_/zip/HEAD" }
      before do
        WebMock.disable_net_connect!
        stub_request(:get, zip_url).to_return(:status => [404, "Not Found"])
      end

      after { WebMock.allow_net_connect! }

      it "raises a DownloadError" do
        msg = "404 - Not Found - Loading URL: https://codeload.github.com/benbalter/_invalid_/zip/HEAD"
        expect { subject.run }.to raise_error(Jekyll::RemoteTheme::DownloadError, msg)
      end
    end

    context "with a large file" do
      let(:zip_url) { "https://codeload.github.com/benbalter/_invalid_/zip/HEAD" }
      let(:content_length) { 10 * 1024 * 1024 * 1024 }
      let(:headers) { { "Content-Length" => content_length } }
      before do
        WebMock.disable_net_connect!
        stub_request(:get, zip_url).to_return(:headers => headers)
      end

      after { WebMock.allow_net_connect! }

      it "raises a DownloadError" do
        msg = "Maximum file size of 1073741824 bytes exceeded"
        expect { subject.run }.to raise_error(Jekyll::RemoteTheme::DownloadError, msg)
      end
    end
  end

  context "with a local theme" do
    let(:tmp_theme_dir) { Dir.mktmpdir("test-theme-") }
    let(:raw_theme) { tmp_theme_dir }

    before do
      # Create a basic theme structure
      FileUtils.mkdir_p(File.join(tmp_theme_dir, "_layouts"))
      File.write(File.join(tmp_theme_dir, "_layouts", "default.html"), "layout content")
      reset_tmp_dir
    end

    after do
      FileUtils.rm_rf(tmp_theme_dir) if Dir.exist?(tmp_theme_dir)
    end

    it "knows it's already downloaded" do
      expect(subject.downloaded?).to be true
    end

    it "doesn't download anything" do
      expect(subject).not_to receive(:download)
      subject.run
    end

    it "doesn't unzip anything" do
      expect(subject).not_to receive(:unzip)
      subject.run
    end
  end
end
