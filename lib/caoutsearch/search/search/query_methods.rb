# frozen_string_literal: true

module Caoutsearch
  module Search
    module Search
      module QueryMethods
        delegate :merge, :merge!, :to_h, :to_json, :as_json, :filters,
          :add_none, :add_filter, :add_sort, :add_aggregation, :add_suggestion,
          :build_terms, :should_filter_on, :must_filter_on, :must_not_filter_on,
          :nested_queries, :nested_query,
          to: :elasticsearch_query

        # Accessors
        # ------------------------------------------------------------------------
        def elasticsearch_query
          @elasticsearch_query ||= Caoutsearch::Search::Query::Base.new
        end

        # Applying criteria
        # ------------------------------------------------------------------------
        def search_by(criteria)
          case criteria
          when Array  then criteria.each { |criterion| search_by(criterion) }
          when Hash   then criteria.each { |key, value| filter_by(key, value) }
          when String then apply_dsl_match_all(criteria)
          end
        end

        def filter_by(key, value)
          case key
          when Array
            items = key.filter_map { |k| config[:filters][k] }
            apply_dsl_filters(items, value)
          when Caoutsearch::Search::DSL::Item
            apply_dsl_filter(key, value)
          else
            if config[:filters].key?(key)
              apply_dsl_filter(config[:filters][key], value)
            elsif config[:filters].key?(:__undef__)
              block = config[:filters][:__undef__]
              instance_exec(key, value, &block)
            end
          end
        end

        # Applying DSL filters items
        # ------------------------------------------------------------------------
        def apply_dsl_match_all(value)
          return unless block = config[:match_all]

          instance_exec(value, &block)
        end

        def apply_dsl_filter(item, value)
          return instance_exec(value, &item.block) if item.has_block?

          terms   = []
          indexes = item.indexes
          options = item.options.dup
          query   = elasticsearch_query

          if options[:nested_query]
            query = nested_query(options[:nested_query])
            options[:nested] = nil
          end

          indexes.each do |index|
            options_index = options.dup
            options_index[:type]              = mappings.find_type(index)          unless options_index.key?(:type)
            options_index[:nested]            = mappings.nested_path(index)        unless options_index.key?(:nested)
            options_index[:include_in_parent] = mappings.include_in_parent?(index) unless options_index.key?(:include_in_parent) || !options_index[:nested]

            terms += query.build_terms(index, value, **options_index)
          end

          query.should_filter_on(terms)
        end

        def apply_dsl_filters(items, value)
          terms = []

          items.each do |item|
            terms += isolate_dsl_filter(item, value)
          end

          should_filter_on(terms)
        end

        def isolate_dsl_filter(item, value)
          isolated_instance = clone
          isolated_instance.apply_dsl_filter(item, value)
          isolated_instance.elasticsearch_query.dig(:query, :bool, :filter) || []
        end

        # Applying orders
        # ------------------------------------------------------------------------
        def order_by(keys)
          case keys
          when Array          then keys.each { |key| order_by(key) }
          when Hash           then keys.each { |key, direction| sort_by(key, direction) }
          when String, Symbol then sort_by(keys)
          end
        end

        def sort_by(key, direction = nil)
          if config[:sorts].key?(key)
            apply_dsl_sort(config[:sorts][key], direction)
          elsif config[:sorts].key?(:__undef__)
            block = config[:sorts][:__undef__]
            instance_exec(key, direction, &block)
          end
        end

        def apply_dsl_sort(item, direction)
          return instance_exec(direction, &item.block) if item.has_block?

          indexes = item.indexes
          indexes.each do |index|
            case index
            when :default, "default"
              sort_by(:default, direction)

            when Hash
              index.map do |key, value|
                key_direction = (value.to_s == direction.to_s ? :asc : :desc)
                add_sort(key, key_direction)
              end

            else
              add_sort(index, direction)
            end
          end
        end

        # Applying aggregations
        # ------------------------------------------------------------------------
        def aggregate_with(*args)
          args.each do |arg|
            if arg.is_a?(Hash)
              arg.each do |key, value|
                next unless item = config[:aggregations][key]

                apply_dsl_aggregate(item, value)
              end
            elsif item = config[:aggregations][arg]
              apply_dsl_aggregate(item)
            end
          end
        end

        def apply_dsl_aggregate(item, *args)
          return instance_exec(*args, &item.block) if item.has_block?

          add_aggregation(item.name, item.options)
        end

        # Applying Suggests
        # ------------------------------------------------------------------------
        def suggest_with(*args)
          args.each do |(hash, options)|
            raise ArgumentError unless hash.is_a?(Hash)

            hash.each do |key, value|
              item = config[:suggestions][key.to_s]
              next unless item = config[:suggestions][key.to_s]

              options ||= {}
              apply_dsl_suggest(item, value, **options)
            end
          end
        end

        def apply_dsl_suggest(item, query, **options)
          return instance_exec(query, **options, &item.block) if item.has_block?

          add_suggestion(item.name, query, **options)
        end
      end
    end
  end
end
