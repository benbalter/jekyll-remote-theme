# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::MockGemspec do
  let(:nwo) { "pages-themes/primer" }
  let(:theme) { Jekyll::RemoteTheme::Theme.new(nwo) }
  subject { described_class.new(theme) }

  it "returns an empty array of runtime dependencies" do
    expect(subject.runtime_dependencies).to eql([])
  end

  it "returns the theme root" do
    expect(subject.full_gem_path).to eql(theme.root)
  end
end
