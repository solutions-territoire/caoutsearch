# frozen_string_literal: true

module Caoutsearch
  module Search
    module Resettable
      def spawn
        clone
      end

      def clone
        super.reset
      end

      def dup
        super.reset
      end

      def reset
        reset_variable(:@elasticsearch_query)
        reset_variable(:@nested_queries)
        reset_variable(:@raw_response)
        reset_variable(:@response)
        reset_variable(:@records)
        reset_variable(:@total_count)
        reset_variable(:@aggregations)
        reset_variable(:@aggregations)
        @loaded = false
        self
      end

      private

      def reset_variable(key)
        remove_instance_variable(key) if instance_variable_defined?(key)
      end
    end
  end
end
