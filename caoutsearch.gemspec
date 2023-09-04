# frozen_string_literal: true

$:.push File.expand_path("lib", __dir__)
require "caoutsearch/version"

Gem::Specification.new do |s|
  s.name = "caoutsearch"
  s.version = Caoutsearch::VERSION

  s.authors = ["Savater Sebastien", "Bailhache Jeanne"]
  s.email = "github.60k5k@simplelogin.co"

  s.homepage = "http://github.com/solutions-territoire/caoutsearch"
  s.licenses = ["MIT"]
  s.summary = "An alternative approach to index & search with Elasticsearch & Ruby on Rails"

  s.files = Dir["lib/**/*"] + %w[LICENSE README.md]
  s.require_paths = ["lib"]

  s.add_dependency "activesupport", ">= 5.0"
  s.add_dependency "elasticsearch", "~> 8.x"
  s.add_dependency "hashie", "~> 5.0"
  s.add_dependency "multi_json", "~> 1.15"
  s.add_dependency "zeitwerk", "~> 2.6"

  s.add_development_dependency "activerecord"
  s.add_development_dependency "amazing_print"
  s.add_development_dependency "appraisal"
  s.add_development_dependency "database_cleaner-active_record"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-rake"
  s.add_development_dependency "rubocop-rspec"
  s.add_development_dependency "rubocop-performance"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "standard", ">= 1.0"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "timecop"
  s.add_development_dependency "webmock"
end
