# frozen_string_literal: true

RSpec.describe "Jekyll::RemoteTheme Caching" do
  let(:raw_theme) { "pages-themes/primer@v0.6.0" }
  let(:config) { {} }
  let(:site) { make_site(config) }
  let(:theme) { Jekyll::RemoteTheme::Theme.new(raw_theme, site) }
  let(:downloader) { Jekyll::RemoteTheme::Downloader.new(theme) }

  before { reset_tmp_dir }
  after do
    FileUtils.rm_rf(theme.root) if Dir.exist?(theme.root)
  end

  context "without cache config" do
    it "cache is not enabled" do
      expect(theme.cache_enabled?).to be_falsy
    end

    it "uses temp directory" do
      expect(theme.root).to include(Jekyll::RemoteTheme::TEMP_PREFIX)
    end

    it "cache_path returns nil" do
      expect(theme.cache_path).to be_nil
    end
  end

  context "with cache enabled" do
    let(:config) do
      {
        "remote_theme_cache" => {
          "enabled" => true,
        },
      }
    end

    it "cache is enabled" do
      expect(theme.cache_enabled?).to be_truthy
    end

    it "uses cache directory" do
      expect(theme.root).to match(/vendor\/cache\/remote-themes/)
    end

    it "includes owner in cache path" do
      expect(theme.root).to include("pages-themes")
    end

    it "includes name in cache path" do
      expect(theme.root).to include("primer")
    end

    it "includes git_ref in cache path" do
      expect(theme.root).to include("v0.6.0")
    end

    it "creates cache directory" do
      expect(Dir.exist?(theme.root)).to be_truthy
    end

    context "with custom cache path" do
      let(:config) do
        {
          "remote_theme_cache" => {
            "enabled" => true,
            "path" => ".cache/themes",
          },
        }
      end

      it "uses custom cache path" do
        expect(theme.root).to include(".cache/themes")
      end
    end

    context "downloading" do
      before do
        downloader.run
      end

      it "downloads the theme" do
        expect(downloader.downloaded?).to be_truthy
      end

      it "extracts the theme to cache directory" do
        expect("#{theme.root}/_layouts/default.html").to be_an_existing_file
      end

      context "on second download" do
        let(:second_downloader) { Jekyll::RemoteTheme::Downloader.new(theme) }

        it "recognizes already downloaded theme" do
          expect(second_downloader.downloaded?).to be_truthy
        end

        it "skips download" do
          expect(Jekyll.logger).to receive(:info).with(
            Jekyll::RemoteTheme::LOG_KEY,
            "Using cached pages-themes/primer@v0.6.0"
          )
          second_downloader.run
        end
      end
    end
  end

  context "with different git refs" do
    let(:config) do
      {
        "remote_theme_cache" => {
          "enabled" => true,
        },
      }
    end

    let(:theme_v1) { Jekyll::RemoteTheme::Theme.new("pages-themes/primer@v0.5.0", site) }
    let(:theme_v2) { Jekyll::RemoteTheme::Theme.new("pages-themes/primer@v0.6.0", site) }

    after do
      FileUtils.rm_rf(theme_v1.root) if Dir.exist?(theme_v1.root)
      FileUtils.rm_rf(theme_v2.root) if Dir.exist?(theme_v2.root)
    end

    it "uses different cache directories" do
      expect(theme_v1.root).not_to eq(theme_v2.root)
    end

    it "v1 cache includes v0.5.0" do
      expect(theme_v1.root).to include("v0.5.0")
    end

    it "v2 cache includes v0.6.0" do
      expect(theme_v2.root).to include("v0.6.0")
    end
  end

  context "path sanitization" do
    let(:config) do
      {
        "remote_theme_cache" => {
          "enabled" => true,
        },
      }
    end

    it "sanitizes path separators in git refs" do
      sanitized = theme.send(:sanitize_path_component, "feature/test-branch")
      expect(sanitized).to eq("feature_test-branch")
      expect(sanitized).not_to include("/")
    end

    it "sanitizes double dots to prevent directory traversal" do
      sanitized = theme.send(:sanitize_path_component, "../../../etc/shadow")
      expect(sanitized).not_to include("..")
      expect(sanitized).to eq("______etc_shadow")
    end

    it "sanitizes backslashes" do
      sanitized = theme.send(:sanitize_path_component, "path\\with\\backslashes")
      expect(sanitized).to eq("path_with_backslashes")
      expect(sanitized).not_to include("\\")
    end

    it "preserves valid version numbers" do
      sanitized = theme.send(:sanitize_path_component, "v1.2.3")
      expect(sanitized).to eq("v1.2.3")
    end

    it "handles nil gracefully" do
      sanitized = theme.send(:sanitize_path_component, nil)
      expect(sanitized).to eq("")
    end
  end
end
