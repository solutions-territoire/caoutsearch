# frozen_string_literal: true

require "bundler/setup"
Bundler.setup

require "simplecov"
SimpleCov.start

require "caoutsearch"
require "caoutsearch/testing"
require "webmock/rspec"
require "amazing_print"

RSpec.configure do |config|
  config.include Caoutsearch::Testing::MockRequests
  config.order = "random"
  config.expect_with :rspec do |expect|
    expect.syntax = :expect
  end
end

def stub_index_class(class_name, &block)
  new_class = Class.new(Caoutsearch::Index::Base)
  stub_const(class_name, new_class)
  new_class.class_eval(&block) if block
  new_class
end

def stub_search_class(class_name, &block)
  new_class = Class.new(Caoutsearch::Search::Base)
  stub_const(class_name, new_class)
  new_class.class_eval(&block) if block
  new_class
end
