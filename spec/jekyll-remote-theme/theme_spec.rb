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

  it "knows its root" do
    expect(Dir.exist?(subject.root)).to be_truthy
  end

  it "exposes gemspec" do
    expect(subject.send(:gemspec)).to be_a(Jekyll::RemoteTheme::MockGemspec)
  end

  it "defaults submodules to false" do
    expect(subject.submodules?).to be_falsy
  end

  context "with submodules enabled" do
    subject { described_class.new(nwo, :submodules => true) }

    it "stores the submodules setting" do
      expect(subject.submodules?).to be_truthy
    end
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
end
