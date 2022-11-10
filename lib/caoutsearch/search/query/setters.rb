# frozen_string_literal: true

module Caoutsearch
  module Search
    module Query
      module Setters
        def add_none
          filters << Caoutsearch::Filter::NONE
        end

        def add_filter(...)
          should_filter_on(build_terms(...))
          self
        end

        # Compose filters
        #
        # Examples :
        #
        #   query.build_terms('key', 'value')
        #   => [ { term: { "key" => "value" } } ] } } }
        #
        #   query.build_terms('key', 'value', type: :integer)
        #   => [ { term: { "key" => 0 } } ] } } }
        #
        #   query.build_terms('key', 'value', as: :boolean)
        #   => [ { term: { "key" => true } } ] } } }
        #
        def build_terms(keys, value, type: :keyword, as: :default, **options)
          filter_class = Caoutsearch::Filter[as]
          raise ArgumentError, "unexpected type of filter: #{as.inspect}" unless filter_class

          terms = Array.wrap(keys).flat_map { |key| filter_class.new(key, value, type, options).as_json }
          terms.select(&:present?)
        rescue Caoutsearch::Search::ValueOverflow
          [Caoutsearch::Filter::NONE]
        end

        def add_sort(prop, direction)
          if direction.to_s == "desc"
            sort.push(prop => direction)
          else
            sort.push(prop)
          end
          self
        end

        def add_aggregation(key, value)
          aggregations[key] = value
        end

        # TODO,
        # Handle types, ex: prefix, input, text
        # Suggestions should probably use _source: false
        def add_suggestion(key, value, **options)
          suggestions[key] = {
            prefix: value,
            completion: options.reverse_merge(
              field: key,
              skip_duplicates: true,
              fuzzy: true
            )
          }
        end
      end
    end
  end
end
