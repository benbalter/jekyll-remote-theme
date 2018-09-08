# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::MockGemspec do
  let(:fixture) { "alldeps" }
  let(:contents) { File.read gemspec_dir("#{fixture}.gemspec") }
  let(:filename) { "#{theme.name}.gemspec" }
  let(:path) { File.expand_path filename, theme.root }
  let(:nwo) { "pages-themes/primer" }
  let(:theme) { Jekyll::RemoteTheme::Theme.new(nwo) }
  subject { described_class.new(theme) }

  before { File.write path, contents }

  it "stores the theme" do
    expect(subject.send(:theme)).to eql(theme)
  end

  it "determines the path" do
    expect(subject.send(:path)).to eql(path)
  end

  it "reads the contents" do
    expect(subject.send(:contents)).to eql(contents)
  end

  it "builds potential_paths" do
    expect(subject.send(:potential_paths)).to include(path)
  end

  it "returns the theme root" do
    expect(subject.full_gem_path).to eql(theme.root)
  end

  context "fixtures" do
    let(:dependency_names) { subject.send(:dependency_names) }
    let(:runtime_dependencies) { subject.runtime_dependencies }

    # Hash in the form of gemspec fixture => expected dependencies
    {
      "alldeps" => %w(jekyll jekyll-feed jekyll-sitemap bundler rake),
      "braces"  => %w(jekyll jekyll-feed jekyll-sitemap bundler rake),
      "rundev"  => %w(jekyll jekyll-feed jekyll-sitemap),
      "nodeps"  => [],
    }.each do |fixture, expected|
      context "the #{fixture} gemspec" do
        let(:fixture) { fixture }

        it "returns dependency names" do
          expect(dependency_names).to eql(expected)
        end

        it "returns #{expected.count} runtime dependencies" do
          expect(runtime_dependencies.count).to eql(expected.count)

          unless expected.empty?
            expect(runtime_dependencies.first).to be_a(Gem::Dependency)
            expect(runtime_dependencies.map(&:name)).to eql(expected)
          end
        end
      end
    end
  end
end
