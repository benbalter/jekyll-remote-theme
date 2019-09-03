# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::Downloader do
  let(:raw_theme) { "pages-themes/primer" }
  let(:theme) { Jekyll::RemoteTheme::Theme.new(raw_theme) }

  let(:source) { source_dir }
  let(:overrides) { {} }
  let(:config) do
    {
      "source" => source,
      "safe" => true,
      "remote_theme" => raw_theme
    }.merge(overrides)
  end
  let(:site) { make_site(config) }



  subject { described_class.new(theme) }

  before { reset_tmp_dir }
  before { reset_cache }
  before { Timecop.freeze(Time.now) }
  before { Jekyll::RemoteTheme.site = site }
  after { Timecop.return }

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

    if defined?(Jekyll::Cache)
      it "stores the timestamp" do
        expect(Jekyll::RemoteTheme.cache["timestamp"]).to eql(Time.now.to_i)
      end
    end
  end

  context "zip_url" do
    it "builds the zip url" do
      expected = "https://codeload.github.com/pages-themes/primer/zip/master"
      expect(subject.send(:zip_url).to_s).to eql(expected)
    end

    context "a custom host" do
      let(:raw_theme) { "http://example.com/pages-themes/primer" }

      it "builds the zip url" do
        expected = "http://codeload.example.com/pages-themes/primer/zip/master"
        expect(subject.send(:zip_url).to_s).to eql(expected)
      end
    end
  end

  context "with zip_url stubbed" do
    before { allow(subject).to receive(:zip_url) { Addressable::URI.parse zip_url } }

    context "with an invalid URL" do
      let(:zip_url) { "https://codeload.github.com/benbalter/_invalid_/zip/master" }
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
      let(:zip_url) { "https://codeload.github.com/benbalter/_invalid_/zip/master" }
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

  context "ttl" do
    context "with the config as a string" do
      it "uses the default TTL" do
        expect(subject.send(:ttl)).to eql(Jekyll::RemoteTheme::DEFAULT_TTL)
      end
    end
  end

  context "cache expiration" do
    if defined?(Jekyll::Cache)
      context "with Jekyll::Cache" do
        context "without a timestamp" do
          before do
            next unless Jekyll::RemoteTheme.cache.key? "timestamp"

            Jekyll::RemoteTheme.cache.delete "timestamp"
          end

          it "is expired" do
            expect(subject.cache_expired?).to be_truthy
          end
        end

        context "with an existing timestamp" do
          before { Jekyll::RemoteTheme.cache["timestamp"] = (Time.now.to_i - 100) }

          it "returns the cache_age" do
            expect(subject.send(:cache_age)).to eql(100)
          end

          it "knows the cache is not expired" do
            expect(subject.cache_expired?).to be_falsy
          end

          context "with an expired cache" do
            before { Jekyll::RemoteTheme.cache["timestamp"] = Time.local(2000).to_i }

            it "knows the cache is expired" do
              expect(subject.cache_expired?).to be_truthy
            end
          end
        end
      end
    else
      context "without Jekyll::Cachhe" do
        it "is always expired" do
          expect(subject.cache_expired?).to be_truthy
        end
      end
    end
  end
end
