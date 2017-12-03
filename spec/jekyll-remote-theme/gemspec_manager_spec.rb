# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::GemspecManager do
  let(:dependencies) do
    [
      ["jekyll", "~> 3.5"],
      ["jekyll-feed", "~> 0.6"],
      ["jekyll-sitemap", "~> 1.5"],
    ]
  end

  %w(alldeps braces rundev).each do |name|
    context "with #{name}.gemspec" do
      let(:gemspec_path) { gemspec_dir "#{name}.gemspec" }
      subject { described_class.new(gemspec_path) }
      let(:spec) { subject.spec_contents.join }

      it "stores a trimmed version of the gemspec" do
        expect(spec).to include("Specification.new")
        expect(spec).to_not include("# frozen_string_literal: true")
        expect(spec).to_not include("require \"#{name}/version\"")
        expect(spec).to_not include("\n\n")
      end

      it "returns an array of dependencies" do
        dependencies.each do |item|
          expect(subject.spec_dependencies).to include(item)
        end
      end
    end
  end

  context "with nodeps.gemspec" do
    subject { described_class.new(gemspec_dir("nodeps.gemspec")) }

    it "returns an empty dependency array" do
      expect(subject.spec_dependencies).to eql([])
    end
  end
end
