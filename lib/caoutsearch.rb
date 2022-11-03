# frozen_string_literal: true

require "active_support/core_ext/module"
require "active_support/core_ext/class"
require "elasticsearch"
require "hashie"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/caoutsearch/testing.rb")
loader.ignore("#{__dir__}/caoutsearch/testing")
loader.inflector.inflect("dsl" => "DSL")
loader.inflector.inflect("internal_dsl" => "InternalDSL")
loader.inflector.inflect("none" => "NONE")
loader.setup

module Caoutsearch
  class << self
    attr_writer :client

    def client
      @client ||= Elasticsearch::Client.new
    end

    def settings
      @settings ||= Caoutsearch::Settings.new({})
    end

    def settings=(settings)
      @settings = Caoutsearch::Settings.new(settings)
    end

    def instrument!(**options)
      @instrumentation_options = options
      Caoutsearch::Instrumentation::Index.attach_to :caoutsearch_index if options[:index]
      Caoutsearch::Instrumentation::Search.attach_to :caoutsearch_search if options[:search]
    end

    def instrumentation_options
      @instrumentation_options ||= {}
    end
  end
end
