# frozen_string_literal: true

module Caoutsearch
  module Search
    module Query
      module Getters
        def filters
          fetch(:query, :bool, :filter, [])
        end

        def aggregations
          fetch(:aggregations, {})
        end

        def suggestions
          fetch(:suggest, {})
        end

        def sort
          fetch(:sort, [])
        end

        def fetch(*keys, default_value)
          value = self

          keys[0..-2].each do |key|
            value = value[key] ||= {}
          end

          value[keys[-1]] ||= default_value
        end
      end
    end
  end
end
