# frozen_string_literal: true

require "bundler/setup"
Bundler.setup

require "simplecov"
SimpleCov.start

require "caoutsearch"
require "caoutsearch/testing"
require "webmock/rspec"
require "amazing_print"
require "active_record"

RSpec.configure do |config|
  config.include Caoutsearch::Testing::MockRequests
  config.order = "random"
  config.expect_with :rspec do |expect|
    expect.syntax = :expect
  end

  config.before(:suite) do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
    ActiveRecord::Schema.define do
      suppress_messages do
        create_table :samples do |t|
          t.string :name
        end
      end
    end
  end

  config.after(:suite) do
    ActiveRecord::Schema.define do
      suppress_messages do
        drop_table :samples
      end
    end
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

def stub_model_class(class_name, &block)
  new_class = Class.new(ActiveRecord::Base)
  stub_const(class_name, new_class)
  new_class.class_eval(&block) if block
  new_class
end
