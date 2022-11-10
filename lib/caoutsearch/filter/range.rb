# frozen_string_literal: true

module Caoutsearch
  module Filter
    class Range < Base
      def filter
        original_values.map do |value|
          case value
          when />(.+)/ then {range: {key => {gt: cast_value_with_overflow($1, :lower)}}}
          when /<(.+)/ then {range: {key => {lt: cast_value_with_overflow($1, :upper)}}}
          when /≥(.+)/ then {range: {key => {gte: cast_value_with_overflow($1, :lower)}}}
          when /≤(.+)/ then {range: {key => {lte: cast_value_with_overflow($1, :upper)}}}
          when /(.+)-(.+)/ then {range: {key => {gte: cast_value_with_overflow($1, :lower), lte: cast_value_with_overflow($2, :upper)}}}
          else {term: {key => cast_value(value)}}
          end
        end
      end

      def cast_value_with_overflow(value, type)
        cast_value(value)
      rescue Caoutsearch::Search::ValueOverflow => e
        raise(e) unless type == e.type

        e.limit
      end
    end
  end
end
