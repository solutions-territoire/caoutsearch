# frozen_string_literal: true

module Caoutsearch
  module Search
    module Query
      module Cleaning
        def clean
          nested_queries.each_value(&:clean)
          remove_duplicate_filters
          remove_empty_clauses
          self
        end

        def remove_duplicate_filters
          filters.replace(filters.uniq) if dig(:query, :bool, :filter)
          self
        end

        def remove_empty_clauses
          each do |key, value|
            delete(key) if value.blank? && value != false
          end

          self
        end
      end
    end
  end
end
