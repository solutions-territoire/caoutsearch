# frozen_string_literal: true

module Caoutsearch
  class Configuration
    DEFAULT_INSTRUMENTATION_FORMAT = "full"

    attr_reader :client, :settings, :instrumentation_format

    def initialize
      self.client = Elasticsearch::Client.new
      self.settings = {}
    end

    def client=(client)
      @client = client

      index.client = client
      search.client = client
    end

    def settings=(settings)
      settings = Caoutsearch::Settings.new(settings) if settings.is_a?(Hash)
      @settings = settings
    end

    def instrument(format = DEFAULT_INSTRUMENTATION_FORMAT)
      @instrumentation_format = format.to_s

      index.instrument(format)
      search.instrument(format)
    end

    def index
      @index ||= IndexConfig.new
      yield(@index) if block_given?
      @index
    end

    def search
      @search ||= SearchConfig.new
      yield(@search) if block_given?
      @search
    end

    class IndexConfig
      attr_accessor :client
      attr_reader :instrumentation_format

      def instrument(format = DEFAULT_INSTRUMENTATION_FORMAT)
        @instrumentation_format = format.to_s
        Caoutsearch::Instrumentation::Index.attach_to :caoutsearch_index
      end
    end

    class SearchConfig
      attr_accessor :client
      attr_reader :instrumentation_format

      def instrument(format = DEFAULT_INSTRUMENTATION_FORMAT)
        @instrumentation_format = format.to_s
        Caoutsearch::Instrumentation::Search.attach_to :caoutsearch_search
      end
    end
  end
end
