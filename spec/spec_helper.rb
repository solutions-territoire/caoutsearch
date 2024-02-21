# frozen_string_literal: true

require "bundler/setup"
Bundler.setup

require "simplecov"

SimpleCov.start do
  add_group "config", %w[lib/caoutsearch.rb lib/caoutsearch/config]
  add_group "index", %w[lib/caoutsearch/index]
  add_group "search", %w[lib/caoutsearch/search lib/caoutsearch/filter lib/caoutsearch/response]
  add_group "testing", %w[lib/caoutsearch/testing]
  add_filter "spec"
end

require "caoutsearch"
require "caoutsearch/testing"
require "webmock/rspec"
require "amazing_print"
require "timecop"

RSpec.configure do |config|
  config.include Caoutsearch::Testing::MockRequests
  config.order = "random"
  config.expect_with :rspec do |expect|
    expect.syntax = :expect
  end

  config.before :context, :active_record do
    require "database_cleaner/active_record"
    require "active_record"

    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
    ActiveRecord::Schema.define do
      suppress_messages do
        create_table :samples do |t|
          t.string :name
        end
      end
    end

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around active_record: true do |example|
    DatabaseCleaner.cleaning { example.run }
  end

  config.after :context, :active_record do
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
