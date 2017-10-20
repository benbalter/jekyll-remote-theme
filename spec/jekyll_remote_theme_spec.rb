# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme do
  let(:source) { source_dir }
  let(:config) { { "source" => source } }
  let(:site) { make_site(config) }
  subject { described_class }

  it "returns the version" do
    expect(subject::VERSION).to match(%r!\d+\.\d+\.\d+!)
  end

  it "inits" do
    expect(subject.init(site)).to be_a(Jekyll::RemoteTheme::Theme)
    expect(site.theme).to be_a(Jekyll::RemoteTheme::Theme)
    expect(File.join(site.theme.root, "_layouts/default.html")).to be_an_existing_file
  end
end
