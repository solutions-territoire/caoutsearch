# frozen_string_literal: true

module Caoutsearch
  module Filter
    class Default < Base
      def filter
        if value.nil? && %w[text keyword].include?(type)
          {
            bool: {
              should: [
                { bool: { must_not: { exists: { field: key } } } },
                { term: { key => "" } }
              ]
            }
          }

        elsif value.nil?
          { bool: { must_not: { exists: { field: key } } } }

        elsif value.is_a?(Array) && value.any?(&:nil?)
          terms = []
          terms << { bool: { must_not: { exists: { field: key } } } }

          terms_values = value.compact
          terms_values += [""] if %w[text keyword].include?(type)

          if terms_values.size == 1
            terms << { term: { key => terms_values[0] } }
          elsif terms_values.size > 1
            terms << { terms: { key => terms_values } }
          end

          if terms.size == 1
            terms[0]
          else
            { bool: { should: terms } }
          end

        elsif value.is_a?(Array) && value.size == 1
          { term: { key => value[0] } }

        elsif value.is_a?(Array)
          { terms: { key => value } }

        else
          { term: { key => value } }
        end
      end
    end
  end
end
