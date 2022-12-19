# frozen_string_literal: true

module Caoutsearch
  module Filter
    class Base
      attr_reader :key, :original_value, :type, :options

      def self.call(...)
        new(...).as_json
      end

      def initialize(key, original_value, type, options = {})
        @key = key
        @original_value = original_value
        @type = type
        @options = options
      end

      def value
        @value = cast_value(original_value) unless defined?(@value)
        @value
      end

      def as_json
        filter = self.filter
        filter = group_filters(filter) if filter.is_a?(Array)

        if filter.present? && nested_query?
          filter = {
            nested: {
              path: nested_path,
              query: {bool: {filter: Array.wrap(filter)}}
            }
          }
        end

        filter
      end

      def filter
        raise NotImplementedError
      end

      protected

      def default_cast_type
        type
      end

      def cast_value(value, type = default_cast_type)
        Caoutsearch::Search::Value.new(
          value,
          type,
          **options.slice(:null_values, :transform)
        ).value
      end

      def original_values
        case original_value
        when String then original_value.split(",")
        when Array then original_value
        else Array.wrap(original_value)
        end
      end

      def group_filters(terms)
        groups = terms.select { |term| term.is_a?(Hash) && (term.key?(:term) || term.key?(:terms)) }
        groups = groups.group_by { |term| (term[:term] || term[:terms]).keys[0] }

        groups.each do |key, grouped_terms|
          next if grouped_terms.size < 2

          values = grouped_terms.flat_map { |term| (term[:term] || term[:terms])[key] }
          values = values.uniq

          grouped_terms.each { |term| terms.delete(term) }

          terms << if values.size == 1
            {term: {key => values[0]}}
          else
            {terms: {key => values}}
          end
        end

        terms
      end

      def nested_query?
        nested_path? && !include_in_parent?
      end

      def nested_path?
        options[:nested] && key.to_s.include?(".")
      end

      def include_in_parent?
        options[:include_in_parent]
      end

      def nested_path
        options[:nested].is_a?(String) ? options[:nested] : key.to_s.split(".")[0].to_sym
      end
    end
  end
end
