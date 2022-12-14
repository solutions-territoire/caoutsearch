# frozen_string_literal: true

module Caoutsearch
  module Search
    class Base
      include Caoutsearch::Config::Client
      include Caoutsearch::Config::Mappings
      include Caoutsearch::Config::Settings

      include Caoutsearch::Search::BatchMethods
      include Caoutsearch::Search::Batch::Scroll
      include Caoutsearch::Search::Batch::SearchAfter
      include Caoutsearch::Search::Callbacks
      include Caoutsearch::Search::DeleteMethods
      include Caoutsearch::Search::Inspect
      include Caoutsearch::Search::Instrumentation
      include Caoutsearch::Search::InternalDSL
      include Caoutsearch::Search::Naming
      include Caoutsearch::Search::PointInTime
      include Caoutsearch::Search::QueryBuilder
      include Caoutsearch::Search::QueryMethods
      include Caoutsearch::Search::Records
      include Caoutsearch::Search::Resettable
      include Caoutsearch::Search::Response
      include Caoutsearch::Search::SearchMethods
    end
  end
end
