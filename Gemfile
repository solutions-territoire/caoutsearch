# frozen_string_literal: true

source "https://rubygems.org"
gemspec

gem "gem-release"
gem "simplecov_json_formatter"

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.1")
  gem "activesupport", ">= 5.0", "< 7.1"
  gem "activerecord", ">= 5.0", "< 7.1"
  gem "sqlite3", "~> 1.4.0"
end
