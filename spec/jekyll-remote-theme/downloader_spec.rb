RSpec.describe Jekyll::RemoteTheme::Downloader do
  let(:nwo) { "foo/bar"}
  let(:theme) { Jekyll::RemoteTheme::Theme.new(nwo) }
  let(:zip_url) { "http://localhost:4000/theme.zip" }
  let(:zip_file) { File.new(zip_file_path) }
  
  subject { described_class.new(theme) }

  before { write_source_dir }
  before { write_zip_file }
  before { allow(subject).to receive(:zip_url).and_return(zip_url) }
  before { allow(subject).to receive(:zip_file).and_return(zip_file) }

  it "knows it's not downloaded" do
    expect(subject.downloaded?).to be_falsy
  end

  context "downloading" do
    before { start_server }
    before { subject.run }
    after { stop_server }

    it "downloads" do
      expect(subject.downloaded?).to be_truthy
    end
  end
end
