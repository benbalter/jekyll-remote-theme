# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::Downloader do
  let(:repository) { nil }
  let(:remote_theme) { nil }
  let(:remote_headers) { nil }
  let(:resolved_zip) { "https://github.com/pages-themes/primer/archive/master.zip" }
  let(:theme) { Jekyll::RemoteTheme::Theme.new(repository, remote_theme) }
  subject { described_class.new(theme, remote_headers) }

  before { reset_tmp_dir }

  shared_examples_for "a downloaded theme" do
    it "knows it's not downloaded" do
      expect(subject.downloaded?).to be_falsy
    end

    it "creates a zip file" do
      expect(subject.send(:zip_file)).to be_an_existing_file
    end

    context "with custom header" do
      let(:remote_headers) { { "Authorization" => "token 1A2B3C4D5E6F7" } }

      it "knows the header" do
        expect(subject.remote_headers["Authorization"]).to eql("token 1A2B3C4D5E6F7")
      end
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
        expect(subject.send(:zip_url).to_s).to eql(resolved_zip)
      end
    end

    context "with zip_url stubbed" do
      before { allow(subject).to receive(:zip_url) { Addressable::URI.parse zip_url } }

      context "with an invalid URL" do
        let(:zip_url) { "https://github.com/benbalter/_invalid_/archive/master.zip" }
        before do
          WebMock.disable_net_connect!
          stub_request(:get, zip_url).to_return(:status => [404, "Not Found"])
        end

        after { WebMock.allow_net_connect! }

        it "raises a DownloadError" do
          msg = "404 - Not Found"
          expect { subject.run }.to raise_error(Jekyll::RemoteTheme::DownloadError, msg)
        end
      end

      context "with a large file" do
        let(:zip_url) { "https://github.com/benbalter/_invalid_/archive/master.zip" }
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
  end

  describe "a remote_theme set to a path with no repository" do
    let(:repository) { nil }
    let(:remote_theme) { "pages-themes/primer" }

    it_should_behave_like "a downloaded theme"
  end

  describe "a remote_theme set to a path with a repository set to an uri" do
    let(:repository) { nil }
    let(:remote_theme) { "https://github.com/pages-themes/primer" }

    it_should_behave_like "a downloaded theme"
  end

  describe "a remote_theme set to a path with a repository set to an uri" do
    let(:repository) { "https://github.com" }
    let(:remote_theme) { "pages-themes/primer" }

    it_should_behave_like "a downloaded theme"
  end
end
