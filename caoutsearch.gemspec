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
  s.add_dependency "hashie", "~> 5.0"
  s.add_dependency "multi_json", "~> 1.15"
  s.add_dependency "zeitwerk", "~> 2.6"
end
