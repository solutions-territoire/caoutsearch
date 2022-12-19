# frozen_string_literal: true

module Caoutsearch
  module Filter
    class Date < Base
      def filter
        original_values.map do |value|
          case value
          when true
            {exists: {field: key}}
          when false
            {bool: {must_not: {exists: {field: key}}}}
          when ::Range, ::Array
            lower_bound = value.is_a?(::Range) ? value.begin : value.first
            upper_bound = value.is_a?(::Range) ? value.end : value.last
            next unless upper_bound || lower_bound

            query = {range: {key => {}}}
            query[:range][key][:gte] = cast_value(lower_bound) if lower_bound

            if upper_bound
              if value.is_a?(::Range) && value.exclude_end?
                query[:range][key][:lt] = cast_value(upper_bound)
              else
                query[:range][key][:lte] = cast_value(upper_bound)
              end
            end

            query
          when ::Date, ::String
            {range: {key => {gte: cast_value(value), lte: cast_value(value)}}}
          when ::Hash
            case value
            in { operator:, value:, **other}
              ActiveSupport::Deprecation.warn("This form of hash to search for dates will be removed")
              unit = other[:unit]

              case operator
              when "less_than"
                {range: {key => {gte: cast_date(value, unit)}}}
              when "greater_than"
                {range: {key => {lt: cast_date(value, unit)}}}
              when "between"
                dates = value.map { |v| cast_date(v, unit) }.sort
                {range: {key => {gte: dates[0], lt: dates[1]}}}
              else
                raise ArgumentError, "unknown operator #{operator.inspect} in #{value.inspect}"
              end
            in { between: dates }
              {range: {key => {
                gte: cast_value(dates.first),
                lte: cast_value(dates.last)
              }}}
            else
              parameters = value.to_h do |operator, value|
                [cast_operator(operator), cast_value(value)]
              end

              {range: {key => parameters}}
            end
          end
        end
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
