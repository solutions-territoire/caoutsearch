# frozen_string_literal: true

module Caoutsearch
  module Index
    class Base
      include Caoutsearch::Config::Client
      include Caoutsearch::Config::Mappings
      include Caoutsearch::Config::Settings

      include Caoutsearch::Index::Document
      include Caoutsearch::Index::Indice
      include Caoutsearch::Index::IndiceVersions
      include Caoutsearch::Index::Instrumentation
      include Caoutsearch::Index::InternalDSL
      include Caoutsearch::Index::Naming
      include Caoutsearch::Index::Reindex
      include Caoutsearch::Index::Scoping
      include Caoutsearch::Index::Serialization

      attr_reader :record

      delegate_missing_to :record

      def initialize(record)
        @record = record
      end

      class << self
        def wrap(*records)
          Array.wrap(*records).map { |record| new(record) }
        end
      end
    end
  end
end
