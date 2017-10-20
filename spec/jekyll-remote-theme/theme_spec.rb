# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::Theme do
  let(:owner) { "foo" }
  let(:name) { "bar" }
  let(:nwo) { "#{owner}/#{name}" }
  let(:git_ref) { nil }
  let(:raw_theme) { git_ref ? "#{nwo}@#{git_ref}" : nwo }
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

  it "defaults git_ref to master" do
    expect(subject.git_ref).to eql("master")
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
end
