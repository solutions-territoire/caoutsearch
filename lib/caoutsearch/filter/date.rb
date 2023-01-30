# frozen_string_literal: true

module Caoutsearch
  module Filter
    class Date < Base
      def filter
        original_values.map do |input|
          case input
          when true
            {exists: {field: key}}
          when false
            {bool: {must_not: {exists: {field: key}}}}
          when ::Date
            {range: {key => {gte: input.as_json, lte: input.as_json}}}
          when ::String
            case input
            when /\A\.\.(.+)\Z/
              build_range_query(..$1)
            when /\A(.+)\.\.\Z/
              build_range_query($1..)
            when /\A(.+)\.\.(.+)\Z/
              build_range_query($1..$2)
            else
              {range: {key => {gte: input, lte: input}}}
            end
          when ::Range, ::Array
            build_range_query(input)
          when ::Hash
            case input
            in { between: dates }
              build_range_query(dates)
            else
              parameters = input.to_h do |operator, value|
                [cast_operator(operator), cast_value(value)]
              end

              {range: {key => parameters}}
            end
          end
        end
      end

      def build_range_query(input)
        lower_bound = input.is_a?(::Range) ? input.begin : input.first
        upper_bound = input.is_a?(::Range) ? input.end : input.last
        return unless upper_bound || lower_bound

        query = {range: {key => {}}}
        query[:range][key][:gte] = cast_value(lower_bound) if lower_bound

        if upper_bound
          if input.is_a?(::Range) && input.exclude_end?
            query[:range][key][:lt] = cast_value(upper_bound)
          else
            query[:range][key][:lte] = cast_value(upper_bound)
          end
        end

        query
      end

      RANGE_OPERATORS = {
        "less_than" => "lt",
        "less_than_or_equal" => "lte",
        "greater_than" => "gt",
        "greater_than_or_equal" => "gte"
      }.freeze

      def cast_operator(original_operator)
        operator = original_operator.to_s
        return original_operator if RANGE_OPERATORS.value?(operator)

        operator = RANGE_OPERATORS[operator]
        if operator.nil?
          raise ArgumentError, "unknown operator #{original_operator.inspect}"
        elsif original_operator.is_a?(Symbol)
          operator.to_sym
        else
          operator
        end
      end

      def cast_date(value, unit)
        if value.is_a?(Numeric) && unit
          case unit
          when "day" then value = value.days.ago.to_date
          when "week" then value = value.weeks.ago.to_date
          when "month" then value = value.months.ago.to_date
          when "year", nil then value = value.years.ago.to_date
          else
            raise ArgumentError, "unknown unit #{unit.inspect} in #{value.inspect}"
          end
        elsif value.is_a?(ActiveSupport::Duration)
          value = value.ago.to_date
        end

        cast_value(value)
      end
    end
  end
end
