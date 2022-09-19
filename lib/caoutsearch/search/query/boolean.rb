# frozen_string_literal: true

module Caoutsearch
  module Search
    module Query
      module Boolean
        def should_filter_on(terms)
          terms              = flatten_bool_terms(:should, terms)
          terms_without_none = terms.without(Caoutsearch::Filter::NONE)
          return if terms.empty?

          if terms.size == 1
            filters << terms[0]
          elsif terms_without_none.size == 1
            filters << terms_without_none[0]
          elsif terms_without_none.size > 1
            filters << { bool: { should: terms_without_none } }
          end
        end

        def must_filter_on(terms)
          terms = flatten_bool_terms(:must, terms)
          return if terms.empty?

          if terms.include?(Caoutsearch::Filter::NONE)
            filters << Caoutsearch::Filter::NONE
          elsif terms.size == 1
            filters << terms[0]
          elsif terms.size > 1
            filters.push(*terms)
          end
        end

        def must_not_filter_on(terms)
          terms = flatten_bool_terms(:must_not, terms)
          terms = terms.without(Caoutsearch::Filter::NONE)
          return if terms.empty?

          filters <<
            if terms.size == 1
              { bool: { must_not: terms[0] } }
            else
              filters << { bool: { must_not: terms } }
            end
        end

        def flatten_bool_terms(operator, raw_terms)
          terms = []

          raw_terms.flatten.each do |value|
            if value.is_a?(Hash) && value.keys == [:bool] && value[:bool].keys == [operator]
              terms += Array.wrap(value.dig(:bool, operator))
            else
              terms << value
            end
          end

          terms.uniq
        end
      end
    end
  end
end
