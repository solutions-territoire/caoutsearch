# frozen_string_literal: true

module Caoutsearch
  module Filter
    class Date < Base
      def filter
        original_values.map do |value|
          case value
          when true
            { exists: { field: key } }
          when false
            { bool: { must_not: { exists: { field: key } } } }
          when Hash
            operator, value, unit = value.stringify_keys.values_at("operator", "value", "unit")

            case operator
            when "less_than"
              { range: { key => { gte: cast_date(value, unit) } } }
            when "greater_than"
              { range: { key => { lt:  cast_date(value, unit) } } }
            when "between"
              dates = value.map { |v| cast_date(v, unit) }.sort
              { range: { key => { gte: dates[0], lt: dates[1] } } }
            else
              raise ArgumentError, "unknown operator #{operator.inspect} in #{value.inspect}"
            end
          end
        end
      end

      def cast_date(value, unit)
        if value.is_a?(Numeric) && unit
          case unit
          when "day"        then value = value.days.ago
          when "week"       then value = value.weeks.ago
          when "month"      then value = value.months.ago
          when "year", nil  then value = value.years.ago
          else
            raise ArgumentError, "unknown unit #{unit.inspect} in #{value.inspect}"
          end
        elsif value.is_a?(ActiveSupport::Duration)
          value = value.ago
        end

        cast_value(value, :date)
      end
    end
  end
end
