# frozen_string_literal: true

module Caoutsearch
  module Search
    module TypeCast
      class << self
        def cast(type, value)
          case type.to_s
          when "integer", "long", "short", "byte"
            cast_as_integer(value)
          when "double", "float", "half_float", "scaled_float"
            cast_as_float(value)
          when "boolean"
            cast_as_boolean(value)
          when "geo_point"
            cast_as_geo_point(value)
          when "date"
            value.to_date.as_json
          else
            value
          end
        end

        def cast_as_integer(value)
          case value
          when nil then nil
          when Array then value.map { |v| cast_as_integer(v) }
          when String then value.delete(" ").to_i
          else value.to_i
          end
        end

        def cast_as_float(value)
          case value
          when nil then nil
          when Array then value.map { |v| cast_as_float(v) }
          when String then value.to_s.delete(" ").tr(",", ".").to_f
          else value.to_f
          end
        end

        # rubocop:disable Lint/BooleanSymbol
        BOOLEAN_FALSE_VALUES = [
          false, 0,
          "0", :"0",
          "f", :f,
          "F", :F,
          "false", :false,
          "FALSE", :FALSE,
          "off", :off,
          "OFF", :OFF
        ].to_set.freeze
        # rubocop:enable Lint/BooleanSymbol

        def cast_as_boolean(value)
          if value == ""
            nil
          else
            BOOLEAN_FALSE_VALUES.exclude?(value)
          end
        end

        def cast_as_geo_point(value)
          if value.is_a? Hash
            value = value.stringify_keys
            value = [value["lat"], value["lon"] || value["lng"]]
          end

          raise ArgumentError, "invalid geo point: #{value.inspect}" unless value.is_a?(Array) && value.length == 2

          value.map(&:to_f).reverse
        end
      end
    end
  end
end
