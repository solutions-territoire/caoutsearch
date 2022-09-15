# frozen_string_literal: true

module Caoutsearch
  module Search
    class Value
      attr_reader :original_value, :type, :null_values, :transform_proc, :overflow_strategy

      def initialize(original_value, type, null_values: nil, transform: nil, sanitize: false)
        @original_value    = original_value
        @type              = type
        @null_values       = Array.wrap(null_values)
        @sanitize_value    = sanitize
        @transform_proc    = transform
        @transform_proc    = transform.to_proc if transform.is_a?(Symbol)
      end

      def value
        unless defined?(@value)
          @value = transform_value(original_value)
          @value = cast_value(@value)
          @value = check_value_overflow(@value)
          @value = strip_value(@value)
          @value = sanitize_value(@value) if sanitize_value?
          @value = replace_null_values(@value)
          @value = reduce_value(@value)
        end

        @value
      end

      def cast_value(value)
        Caoutsearch::Search::TypeCast.cast(type, value)
      end

      def sanitize_value(value)
        Caoutsearch::Search::Sanitizer.sanitize(value)
      end

      def sanitize_value?
        !!@sanitize_value
      end

      def check_value_overflow(value)
        if value.is_a?(Array)
          value.map { |v| check_value_overflow(v) }
        elsif value.nil?
          value
        else
          range = INTEGER_TYPE_LIMITS[type.to_s]

          if range
            raise Caoutsearch::Search::ValueOverflow.new(:lower, value, range.first) if value < range.first
            raise Caoutsearch::Search::ValueOverflow.new(:upper, value, range.last)  if range && value > range.last
          end

          value
        end
      end

      def self.bytes_size_to_integer_range(bytes_size)
        limit = 2**(bytes_size - 1)
        -limit..(limit - 1)
      end

      INTEGER_TYPE_LIMITS = {
        "long"    => bytes_size_to_integer_range(64),
        "integer" => bytes_size_to_integer_range(32),
        "short"   => bytes_size_to_integer_range(16),
        "byte"    => bytes_size_to_integer_range(8)
      }.freeze

      def transform_value(value)
        if value.is_a?(Array)
          value.flat_map { |v| transform_value(v) }

        elsif transform_proc.respond_to?(:call)
          transform_proc.call(value)

        else
          value
        end
      end

      def strip_value(value)
        value = value.strip if value.is_a?(String)
        value
      end

      def replace_null_values(value)
        if value.is_a?(Array)
          value.map { |v| replace_null_values(v) }

        elsif null_values.include?(value)
          nil

        else
          value
        end
      end

      def reduce_value(value)
        if value.is_a?(Array) && value.size == 1
          value[0]

        else
          value
        end
      end
    end
  end
end
