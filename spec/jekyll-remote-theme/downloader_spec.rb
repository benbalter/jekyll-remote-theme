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

    context "with an SSL error" do
      let(:zip_url) { "https://codeload.github.com/benbalter/_ssl_error_/zip/HEAD" }
      let(:ssl_error_msg) { "certificate verify failed (unable to get certificate CRL)" }
      before do
        WebMock.disable_net_connect!
        stub_request(:get, zip_url).to_raise(OpenSSL::SSL::SSLError.new(ssl_error_msg))
      end

      after { WebMock.allow_net_connect! }

      it "raises a DownloadError for SSL errors" do
        expect { subject.run }.to raise_error(Jekyll::RemoteTheme::DownloadError, ssl_error_msg)
      end
    end
  end

  context "proxy configuration" do
    after do
      ENV.delete("http_proxy")
      ENV.delete("https_proxy")
      ENV.delete("HTTP_PROXY")
      ENV.delete("HTTPS_PROXY")
    end

    it "returns nil proxy_uri when no proxy is set" do
      expect(subject.send(:proxy_uri)).to be_nil
    end

    it "returns nil proxy_host when no proxy is set" do
      expect(subject.send(:proxy_host)).to be_nil
    end

    it "parses http_proxy environment variable" do
      ENV["http_proxy"] = "http://proxy.example.com:8080"
      expect(subject.send(:proxy_host)).to eq("proxy.example.com")
      expect(subject.send(:proxy_port)).to eq(8080)
    end

    it "parses https_proxy environment variable for https URLs" do
      ENV["https_proxy"] = "http://secure-proxy.example.com:8443"
      expect(subject.send(:proxy_host)).to eq("secure-proxy.example.com")
      expect(subject.send(:proxy_port)).to eq(8443)
    end

    it "prefers https_proxy over http_proxy for https URLs" do
      ENV["http_proxy"] = "http://proxy.example.com:8080"
      ENV["https_proxy"] = "http://secure-proxy.example.com:8443"
      expect(subject.send(:proxy_host)).to eq("secure-proxy.example.com")
      expect(subject.send(:proxy_port)).to eq(8443)
    end

    it "parses proxy with authentication" do
      ENV["http_proxy"] = "http://user:password@proxy.example.com:8080"
      expect(subject.send(:proxy_host)).to eq("proxy.example.com")
      expect(subject.send(:proxy_port)).to eq(8080)
      expect(subject.send(:proxy_user)).to eq("user")
      expect(subject.send(:proxy_pass)).to eq("password")
    end

    it "handles uppercase environment variables" do
      ENV["HTTP_PROXY"] = "http://proxy.example.com:8080"
      expect(subject.send(:proxy_host)).to eq("proxy.example.com")
      expect(subject.send(:proxy_port)).to eq(8080)
    end

    it "returns Net::HTTP class when no proxy is set" do
      expect(subject.send(:http_class)).to eq(Net::HTTP)
    end

    it "returns Net::HTTP::Proxy class when proxy is set" do
      ENV["http_proxy"] = "http://proxy.example.com:8080"
      http_class = subject.send(:http_class)
      expect(http_class).not_to eq(Net::HTTP)
      expect(http_class.proxy_address).to eq("proxy.example.com")
      expect(http_class.proxy_port).to eq(8080)
    end

    it "handles invalid proxy URIs gracefully" do
      ENV["http_proxy"] = "://invalid"
      expect(subject.send(:proxy_host)).to be_nil
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
      FileUtils.rm_rf(tmp_theme_dir)
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
