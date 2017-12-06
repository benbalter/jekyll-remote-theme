# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::DependencyManager do
  let(:theme) { Jekyll::RemoteTheme::Theme.new("owner/theme-name") }
  let(:dependencies) { ["jekyll", "jekyll-feed", "jekyll-sitemap"] }
  subject { described_class.new(theme, dependencies) }

  %w(alldeps braces rundev).each do |name|
    context "with #{name}.gemspec" do
      it "returns an array of dependency gem names" do
        subject.instance_variable_set(:@gemspec, gemspec_dir("#{name}.gemspec"))
        subject.extract_dependencies
        dependencies.each do |item|
          expect(subject.theme_dependencies).to include(item)
        end
      end
    end
  end

  context "with nodeps.gemspec" do
    it "returns an empty dependency array" do
      subject.instance_variable_set(:@gemspec, gemspec_dir("nodeps.gemspec"))
      subject.extract_dependencies
      expect(subject.theme_dependencies).to eql([])
    end
  end
end
