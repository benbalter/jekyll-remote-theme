RSpec.describe Jekyll::RemoteTheme::Cloner do
  let(:git_url) { git_repo }
  let(:git_ref) { "master" }
  let(:path) { File.expand_path "_theme", dest_dir }

  subject { described_class.new(:git_url => git_url, :git_ref => git_ref, :path => path) }

  before { reset_tmp_dir }
  before { write_git_repo }
  before { Jekyll.logger.log_level = :error }

  it "stores the git_url" do
    expect(subject.git_url).to eql(git_url)
  end

  it "stores the git_ref" do
    expect(subject.git_ref).to eql(git_ref)
  end

  it "stores the path" do
    expect(subject.path).to eql(path)
  end

  context "when path is nil" do
    subject do
      described_class.new(:git_url => git_url, :git_ref => git_ref, :path => nil)
    end

    it "doesn't clone" do
      expect(subject.run).to be_falsy
    end
  end

  context "when the theme dir exists" do
    before { FileUtils.mkdir_p path }

    it "doesn't clone" do
      expect(subject.run).to be_falsy
    end
  end

  context "a valid theme" do
    it "clones" do
      layout_path = File.expand_path "_layouts/default.html", path
      expect(File.exist?(layout_path)).to be_falsy

      expect(subject.run).to be_truthy
      expect(File.exist?(layout_path)).to be_truthy
    end
  end

  context "an invalid theme" do
    let(:git_url) { File.expand_path "foo", tmp_dir }
    before { FileUtils.rm_rf git_url }

    it "raises an error" do
      expect { subject.run }.to raise_error(Jekyll::RemoteTheme::Cloner::CloneError)
    end
  end
end
