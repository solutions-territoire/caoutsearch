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

  s.add_dependency "elastisearch"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "zeitwerk"
end
