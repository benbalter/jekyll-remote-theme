# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::Theme do
  let(:remote_host) { nil }
  let(:remote_theme) { nil }
  subject { described_class.new(remote_host, remote_theme) }

  shared_examples_for "a theme" do
    let(:scheme) { uri.scheme }
    let(:host) { uri.host }
    let(:nwo) { "#{owner}/#{name}" }

    it "parses the theme url scheme" do
      expect(subject.scheme).to eql(scheme)
    end

    it "parses the theme url host" do
      expect(subject.host).to eql(host)
    end

    it "parses the theme owner" do
      expect(subject.owner).to eql(owner)
    end

    it "parses the theme name" do
      expect(subject.name).to eql(name)
    end

    it "parses the theme git_ref" do
      expect(subject.git_ref).to eql(git_ref)
    end

    it "builds the name with owner" do
      expect(subject.name_with_owner).to eql(nwo)
      expect(subject.nwo).to eql(nwo)
    end

    it "knows it's valid" do
      expect(subject).to be_valid
    end

    it "knows its root" do
      expect(Dir.exist?(subject.root)).to be_truthy
    end

    it "exposes gemspec" do
      expect(subject.send(:gemspec)).to be_a(Jekyll::RemoteTheme::MockGemspec)
    end
  end

  context "with a remote_theme set as a path without remote_host" do
    let(:remote_host) { nil }
    let(:remote_theme) { "custom/theme" }

    it_should_behave_like "a theme" do
      let(:uri) { Addressable::URI.parse("https://github.com/#{remote_theme}") }
      let(:owner) { "custom" }
      let(:name) { "theme" }
      let(:git_ref) { "master" }
    end
  end

  context "with a remote_theme set to a uri without remote_host" do
    let(:remote_host) { nil }
    let(:remote_theme) { "https://custom.com/custom/theme" }

    it_should_behave_like "a theme" do
      let(:uri) { Addressable::URI.parse("https://custom.com/#{remote_theme}") }
      let(:owner) { "custom" }
      let(:name) { "theme" }
      let(:git_ref) { "master" }
    end
  end

  context "with a remote_theme set to a path with remote_host set to an uri" do
    let(:remote_host) { "https://custom.com" }
    let(:remote_theme) { "custom/theme" }

    it_should_behave_like "a theme" do
      let(:uri) { Addressable::URI.parse("https://custom.com/#{remote_theme}") }
      let(:owner) { "custom" }
      let(:name) { "theme" }
      let(:git_ref) { "master" }
    end
  end

  context "with a remote_theme set" do
    let(:remote_host) { nil }

    context "to a path with no owner/name structure" do
      let(:remote_theme) { "foo" }

      it "isn't valid" do
        expect(subject).to_not be_valid
      end
    end

    context "to an array" do
      let(:remote_theme) { [1, 2] }

      it "isn't valid" do
        expect(subject).to_not be_valid
      end
    end

    context "to a path with invalid characters" do
      let(:remote_theme) { "custom/@£¢£¤" }

      it "isn't valid" do
        expect(subject).to_not be_valid
      end
    end

    context "to a long path" do
      let(:remote_theme) { "very/long/path/custom" }

      it "isn't valid" do
        expect(subject).to_not be_valid
      end
    end

    context "to a git reference name stable" do
      let(:remote_theme) { "path/custom@stable" }

      it "parses to stable" do
        expect(subject.git_ref).to eql("stable")
      end
    end
  end
end
