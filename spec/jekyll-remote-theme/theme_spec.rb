# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::Theme do
  let(:scheme) { nil }
  let(:host) { nil }
  let(:owner) { "foo" }
  let(:name) { "bar" }
  let(:nwo) { "#{owner}/#{name}" }
  let(:git_ref) { nil }
  let(:raw_theme) do
    raw_theme = +""
    raw_theme << "#{scheme}://#{host}/" if scheme && host
    raw_theme << nwo.to_s
    raw_theme << "@#{git_ref}" if git_ref
    raw_theme
  end
  subject { described_class.new(raw_theme) }

  it "stores the theme" do
    expect(subject.instance_variable_get("@raw_theme")).to eql(nwo)
  end

  context "with an abnormal NWO" do
    let(:nwo) { " FoO/bAr " }

    it "normalizes the nwo" do
      expect(subject.instance_variable_get("@raw_theme")).to eql("foo/bar")
    end
  end

  it "extracts the name" do
    expect(subject.name).to eql(name)
  end

  it "extracts the owner" do
    expect(subject.owner).to eql(owner)
  end

  it "uses the default host" do
    expect(subject.host).to eql("github.com")
  end

  it "uses the default scheme" do
    expect(subject.scheme).to eql("https")
  end

  it "builds the name with owner" do
    expect(subject.name_with_owner).to eql(nwo)
    expect(subject.nwo).to eql(nwo)
  end

  it "knows it's valid" do
    expect(subject).to be_valid
  end

  context "a random string" do
    let(:nwo) { "foo" }

    it "isn't valid" do
      expect(subject).to_not be_valid
    end
  end

  context "with a non-string" do
    let(:nwo) { [1, 2] }

    it "isn't valid" do
      expect(subject).to_not be_valid
    end
  end

  context "with a non-nwo string" do
    let(:nwo) { "foo/javascript: alert(1);" }

    it "isn't valid" do
      expect(subject).to_not be_valid
    end
  end

  it "defaults git_ref to HEAD" do
    expect(subject.git_ref).to eql("HEAD")
  end

  context "with a git_ref" do
    let(:git_ref) { "foo" }

    it "parses the git ref" do
      expect(subject.git_ref).to eql(git_ref)
    end
  end

  context "with @latest ref" do
    let(:git_ref) { "latest" }
    let(:api_response_body) { '{"tag_name": "v1.2.3"}' }

    before do
      allow(subject).to receive(:fetch_latest_release_tag).and_return("v1.2.3")
    end

    it "resolves to the latest release tag" do
      expect(subject.git_ref).to eql("v1.2.3")
    end

    context "when no releases exist" do
      before do
        allow(subject).to receive(:fetch_latest_release_tag).and_return(nil)
      end

      it "falls back to HEAD" do
        expect(subject.git_ref).to eql("HEAD")
      end
    end

    context "when API call fails" do
      before do
        allow(subject).to receive(:fetch_latest_release_tag).and_return(nil)
      end

      it "falls back to HEAD" do
        expect(subject.git_ref).to eql("HEAD")
      end
    end
  end

  it "knows its root" do
    expect(Dir.exist?(subject.root)).to be_truthy
  end

  it "exposes gemspec" do
    expect(subject.send(:gemspec)).to be_a(Jekyll::RemoteTheme::MockGemspec)
  end

  context "a full URL" do
    let(:host) { "github.com" }
    let(:scheme) { "https" }

    it "extracts the name" do
      expect(subject.name).to eql(name)
    end

    it "extracts the owner" do
      expect(subject.owner).to eql(owner)
    end

    it "extracts the host" do
      expect(subject.host).to eql("github.com")
    end

    it "extracts the scheme" do
      expect(subject.scheme).to eql("https")
    end

    it "is valid" do
      with_env "GITHUB_HOSTNAME", "enterprise.github.com" do
        expect(subject).to be_valid
      end
    end

    context "a custom host" do
      let(:host) { "example.com" }
      let(:scheme) { "http" }

      it "extracts the name" do
        expect(subject.name).to eql(name)
      end

      it "extracts the owner" do
        expect(subject.owner).to eql(owner)
      end

      it "extracts the host" do
        expect(subject.host).to eql(host)
      end

      it "extracts the scheme" do
        expect(subject.scheme).to eql(scheme)
      end

      it "is valid if a whitelisted host name" do
        with_env "GITHUB_HOSTNAME", "example.com" do
          expect(subject).to be_valid
        end
      end

      it "is invalid if not a whitelisted host name" do
        with_env "GITHUB_HOSTNAME", "enterprise.github.com" do
          expect(subject).to_not be_valid
        end
      end

      context "with a git ref" do
        let(:git_ref) { "foo" }

        it "parses the git ref" do
          expect(subject.git_ref).to eql(git_ref)
        end
      end
    end
  end

  context "with a local path" do
    let(:tmp_theme_dir) { Dir.mktmpdir("test-theme-") }
    let(:raw_theme) { tmp_theme_dir }

    before do
      # Create a basic theme structure
      FileUtils.mkdir_p(File.join(tmp_theme_dir, "_layouts"))
      File.write(File.join(tmp_theme_dir, "_layouts", "default.html"), "layout content")
    end

    after do
      FileUtils.rm_rf(tmp_theme_dir)
    end

    it "detects as a local theme" do
      expect(subject.local_theme?).to be true
    end

    it "is valid when directory exists" do
      expect(subject).to be_valid
    end

    it "extracts the name from path" do
      expect(subject.name).to eql(File.basename(tmp_theme_dir))
    end

    it "uses 'local' as the owner" do
      expect(subject.owner).to eql("local")
    end

    it "uses the expanded path as root" do
      expect(subject.root).to eql(File.expand_path(tmp_theme_dir))
    end

    it "returns nil for host" do
      expect(subject.host).to be_nil
    end

    it "returns nil for scheme" do
      expect(subject.scheme).to be_nil
    end

    context "with a relative path" do
      let(:raw_theme) { "../relative-theme" }

      it "detects as a local theme" do
        expect(subject.local_theme?).to be true
      end

      it "is invalid when directory doesn't exist" do
        expect(subject).to_not be_valid
      end
    end

    context "with ./relative path" do
      let(:raw_theme) { "./local-theme" }

      it "detects as a local theme" do
        expect(subject.local_theme?).to be true
      end
    end

    context "with an absolute path that doesn't exist" do
      let(:raw_theme) { "/nonexistent/theme/path" }

      it "detects as a local theme" do
        expect(subject.local_theme?).to be true
      end

      it "is invalid when directory doesn't exist" do
        expect(subject).to_not be_valid
      end
    end

    context "with a tilde path" do
      let(:raw_theme) { "~/nonexistent-theme" }

      it "detects as a local theme" do
        expect(subject.local_theme?).to be true
      end

      it "is invalid when directory doesn't exist" do
        expect(subject).to_not be_valid
      end
    end
  end

  context "with @latest ref and real API calls" do
    let(:git_ref) { "latest" }
    let(:api_url) { "https://api.github.com/repos/foo/bar/releases/latest" }
    let(:api_response_body) { '{"tag_name": "v2.5.0"}' }

    before do
      WebMock.disable_net_connect!
      stub_request(:get, api_url)
        .to_return(
          :status  => 200,
          :body    => api_response_body,
          :headers => { "Content-Type" => "application/json" }
        )
    end

    after { WebMock.allow_net_connect! }

    it "fetches the latest release from GitHub API" do
      expect(subject.git_ref).to eql("v2.5.0")
    end

    context "when the API returns 404" do
      before do
        stub_request(:get, api_url).to_return(:status => 404)
      end

      it "falls back to HEAD" do
        expect(subject.git_ref).to eql("HEAD")
      end
    end

    context "when the API call raises an error" do
      before do
        stub_request(:get, api_url).to_raise(StandardError.new("Network error"))
      end

      it "falls back to HEAD" do
        expect(subject.git_ref).to eql("HEAD")
      end
    end

    context "when the API returns malformed JSON" do
      before do
        stub_request(:get, api_url)
          .to_return(:status => 200, :body => "not valid json")
      end

      it "falls back to HEAD" do
        expect(subject.git_ref).to eql("HEAD")
      end
    end

    context "when the API returns JSON without tag_name" do
      before do
        stub_request(:get, api_url)
          .to_return(
            :status  => 200,
            :body    => '{"name": "Release 1"}',
            :headers => { "Content-Type" => "application/json" }
          )
      end

      it "falls back to HEAD" do
        expect(subject.git_ref).to eql("HEAD")
      end
    end

    context "when the API returns empty tag_name" do
      before do
        stub_request(:get, api_url)
          .to_return(
            :status  => 200,
            :body    => '{"tag_name": ""}',
            :headers => { "Content-Type" => "application/json" }
          )
      end

      it "falls back to HEAD" do
        expect(subject.git_ref).to eql("HEAD")
      end
    end
  end
end
