# frozen_string_literal: true

$:.push File.expand_path("lib", __dir__)
require "caoutsearch/version"

Gem::Specification.new do |s|
  s.name    = "caoutsearch"
  s.version = Caoutsearch::VERSION

  s.authors = ["Savater Sebastien", "Bailhache Jeanne"]
  s.email   = "github.60k5k@simplelogin.co"

  s.homepage = "http://github.com/mon-territoire/caoutsearch"
  s.licenses = ["MIT"]
  s.summary  = "An alternative approach to index & search with Elasticsearch & Ruby on Rails"

  s.files         = Dir["lib/**/*"] + %w[LICENSE README.md]
  s.require_paths = ["lib"]

  s.add_dependency "activesupport", ">= 5.0"
  s.add_dependency "elasticsearch", "~> 8.x"
  s.add_dependency "zeitwerk", "~> 2.6.0"

  s.add_development_dependency "bundler"
  s.add_development_dependency "gem-release"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-rake"
  s.add_development_dependency "rubocop-rspec"
  s.add_development_dependency "rubocop-performance"
  s.add_development_dependency "standard"
end
