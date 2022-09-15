# frozen_string_literal: true

module Caoutsearch
  module Filter
    class BoundingBox < Base
      def filter
        {
          geo_bounding_box: {
            key => {
              top_left:     top_left_value,
              bottom_right: bottom_right_value
            }
          }
        }
      end

      def value
        unless defined?(@value)
          case original_value
          when Hash
            value = original_value.stringify_keys

            if value.key?("north")
              ne = value.values_at("north", "east")
              sw = value.values_at("south", "west")
            elsif value.key?("ne")
              ne = value["ne"]
              sw = value["sw"]
            end

            @value = [
              cast_value(ne),
              cast_value(sw)
            ]

          when Array
            @value = [
              cast_value(original_value[0..1]),
              cast_value(original_value[2..3])
            ]
          end
        end

        @value
      end

      def top_left_value
        value[0]
      end

      def bottom_right_value
        value[1]
      end
    end
  end
end
