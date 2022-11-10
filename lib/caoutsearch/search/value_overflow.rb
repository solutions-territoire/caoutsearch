# frozen_string_literal: true

module Caoutsearch
  module Search
    class ValueOverflow < StandardError
      attr_reader :value, :limit, :type

      def initialize(type, value, limit)
        @type = type
        @value = value
        @limit = limit

        super("the value #{value.inspect} exceeds the #{type} limit (#{limit})")
      end
    end
  end
end
