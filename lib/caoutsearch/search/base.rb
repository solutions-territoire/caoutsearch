# frozen_string_literal: true

module Caoutsearch
  module Search
    class Base
      include Caoutsearch::Config::Client
      include Caoutsearch::Config::Mappings
      include Caoutsearch::Config::Settings

      include Caoutsearch::Search::Search::DeleteMethods
      include Caoutsearch::Search::Search::Inspect
      include Caoutsearch::Search::Search::Instrumentation
      include Caoutsearch::Search::Search::InternalDSL
      include Caoutsearch::Search::Search::Naming
      include Caoutsearch::Search::Search::QueryBuilder
      include Caoutsearch::Search::Search::QueryMethods
      include Caoutsearch::Search::Search::Resettable
      include Caoutsearch::Search::Search::Response
      include Caoutsearch::Search::Search::ScrollMethods
      include Caoutsearch::Search::Search::SearchMethods
    end
  end
end
