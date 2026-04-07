# frozen_string_literal: true

module Caoutsearch
  module Filter
    class Boolean < Base
      def filter
        return {} if value.nil?

        if value.is_a?(Array)
          {terms: {key => value}}
        else
          {term: {key => value}}
        end
      end

      protected

      def default_cast_type
        "boolean"
      end
    end
  end
end
