# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "dsl" => "DSL",
  "internal_dsl" => "InternalDSL",
  "none" => "NONE"
)
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
