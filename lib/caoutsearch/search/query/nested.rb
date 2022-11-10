# frozen_string_literal: true

module Caoutsearch
  module Search
    module Query
      module Nested
        def nested_queries
          @nested_queries ||= {}
        end

        def nested_query(path)
          nested_queries[path.to_s] ||= begin
            query = Caoutsearch::Search::Query::Base.new
            query[:path] = path.to_s

            filters << {nested: query}
            query
          end
        end
      end
    end
  end
end
