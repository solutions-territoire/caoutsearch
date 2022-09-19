# frozen_string_literal: true

module Caoutsearch
  module Search
    module Search
      module Inspect
        PROPERTIES_TO_INSPECT = %i[
          search_criteria
          current_context
          current_order
          current_page
          current_limit
          current_offset
          current_aggregations
          current_suggestions
          current_returns
        ].freeze

        def inspect
          properties = properties_to_inspect.map { |k, v| " #{k}: #{v}" }

          "#<#{self.class}#{properties.join(",")}>"
        end

        private

        def properties_to_inspect
          PROPERTIES_TO_INSPECT.each_with_object({}) do |name, properties|
            value = instance_variable_get("@#{name}")
            properties[name] = value.inspect if value
          end
        end
      end
    end
  end
end
