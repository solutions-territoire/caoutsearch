# frozen_string_literal: true

module Caoutsearch
  module Filter
    class Match < Base
      def filter
        if use_query_string?
          {
            query_string: {
              query:            sanitized_for_query_string,
              default_field:    key,
              default_operator: "and",
              analyze_wildcard: true
            }
          }
        elsif multiple_words?
          { match: { key => { query: value, operator: "and" } } }
        else
          { match: { key => value } }
        end
      end

      def nested_query?
        nested_path? && (multiple_words? || !include_in_parent?)
      end

      def multiple_words?
        value.is_a?(String) && value.squish.include?(" ")
      end

      # https://rubular.com/r/KEA7poAaIeNrZe
      QUERY_STRING_REGEXP = %r{
        (?:[*?][^\s*?]|[^\s*?][*?]|(?:^|\s)(?:AND|OR|NOT)(?:$|\s)|^\*$)
      }x.freeze

      # https://rubular.com/r/tVMSviF0a74e1s
      STRIPPED_OPERATOR_REGEXP = %r{
        (?:^\s*(?:AND|OR)\*$|^\s*(?:AND|OR)\s+|\s+(?:AND|OR)\s*$)
      }x.freeze

      def use_query_string?
        QUERY_STRING_REGEXP.match?(value)
      end

      def sanitized_for_query_string
        # Do not allow setting fields in query string
        clean_value = Caoutsearch::Search::Sanitizer.sanitize(value, ":")

        # Delete leading and trailing operators
        # Example : " OR ANGE"  => "ANGE"
        # Example : "MASSE OR " => "MASSE"

        clean_value.gsub(STRIPPED_OPERATOR_REGEXP, "")
      end
    end
  end
end
