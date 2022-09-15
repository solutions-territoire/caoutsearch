# frozen_string_literal: true

module Caoutsearch
  module Filter
    class Boolean < Base
      def filter
        return {} if value.nil?

        { term: { key => value } }
      end

      protected

      def default_cast_type
        "boolean"
      end
    end
  end
end
