# frozen_string_literal: true

module Caoutsearch
  module Search
    module Query
      class Base < ::Hash
        include Caoutsearch::Search::Query::Boolean
        include Caoutsearch::Search::Query::Cleaning
        include Caoutsearch::Search::Query::Getters
        include Caoutsearch::Search::Query::Merge
        include Caoutsearch::Search::Query::Nested
        include Caoutsearch::Search::Query::Setters
      end
    end
  end
end
