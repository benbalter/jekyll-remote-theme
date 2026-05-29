# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "jekyll", ENV["JEKYLL_VERSION"] if ENV["JEKYLL_VERSION"]
gem "jekyll-github-metadata", :github => "jekyll/github-metadata"

# rubocop-jekyll pins us to rubocop 1.57.x, which still calls the
# EnsureNode#body method that rubocop-ast deprecated in 1.38.0. Pin
# rubocop-ast below that to avoid the deprecation warning.
gem "rubocop-ast", "< 1.38"
