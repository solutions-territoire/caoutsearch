# frozen_string_literal: true

module Caoutsearch
  module Search
    module Search
      module SearchMethods
        attr_reader :current_context, :current_order, :current_aggregations,
          :current_suggestions, :current_fields, :current_source

        # Public API
        # ------------------------------------------------------------------------
        def search(*values)
          spawn.search!(*values)
        end

        def context(value)
          spawn.context!(value)
        end

        def order(value)
          spawn.order!(value)
        end

        def page(value)
          spawn.page!(value)
        end

        def limit(value)
          spawn.limit!(value)
        end
        alias_method :per, :limit

        def offset(value)
          spawn.offset!(value)
        end

        def aggregate(*values)
          spawn.aggregate!(*values)
        end

        def suggest(values, **options)
          spawn.suggest!(values, **options)
        end

        def fields(*values)
          spawn.fields!(*values)
        end
        alias_method :returns, :fields

        def source(*values)
          spawn.source!(*values)
        end
        alias_method :with_sources, :source

        def without_sources
          spawn.source!(false)
        end

        def without_hits
          spawn.source!(false).limit!(0)
        end

        def unscope(key)
          spawn.unscope!(key)
        end

        def prepend(hash)
          spawn.prepend!(hash)
        end

        def append(hash)
          spawn.append!(hash)
        end

        # Setters
        # ------------------------------------------------------------------------
        def search!(*values)
          values = values.flatten.map do |value|
            value = value.stringify_keys if value.is_a?(Hash)
            value
          end

          @search_criteria ||= []
          @search_criteria += values
          self
        end

        def context!(value)
          @current_context = value
          self
        end

        def order!(value)
          @current_order = value
          self
        end

        def page!(value)
          @current_page = value
          self
        end

        def limit!(value)
          @current_limit = value
          self
        end

        def offset!(value)
          @current_offset = value
          self
        end

        def aggregate!(*values)
          @current_aggregations ||= []
          @current_aggregations += values.flatten
          self
        end

        def suggest!(values, **options)
          raise ArgumentError unless values.is_a?(Hash)

          @current_suggestions ||= []
          @current_suggestions << [values, options]
          self
        end

        def fields!(*values)
          @current_fields ||= []
          @current_fields += values.flatten
          self
        end

        def source!(*values)
          @current_source ||= []
          @current_source += values.flatten
          self
        end

        def prepend!(hash)
          @prepend_hash = hash
          self
        end

        def append!(hash)
          @append_hash = hash
          self
        end

        UNSCOPE_KEYS = {
          "search"          => :@search_criteria,
          "search_criteria" => :@search_criteria,
          "limit"           => :@current_limit,
          "per"             => :@current_limit,
          "aggregate"       => :@current_aggregations,
          "aggregations"    => :@current_aggregations,
          "suggest"         => :@current_suggestions,
          "suggestions"     => :@current_suggestions,
          "context"         => :@current_context,
          "order"           => :@current_order,
          "page"            => :@current_page,
          "offset"          => :@current_offset,
          "fields"          => :@current_fields,
          "source"          => :@current_source
        }.freeze

        def unscope!(key)
          raise ArgumentError unless (variable = UNSCOPE_KEYS[key.to_s])

          reset_variable(variable)
          self
        end

        # Getters
        # ------------------------------------------------------------------------
        def search_criteria
          @search_criteria ||= []
        end

        def current_page
          @current_page&.to_i || 1
        end

        def current_limit
          @current_limit&.to_i || 10
        end

        def current_offset
          if @current_offset
            @current_offset.to_i
          elsif @current_page
            (current_limit * (current_page - 1))
          else
            0
          end
        end

        # Criteria handlers
        # ------------------------------------------------------------------------
        def find_criterion(key)
          key = key.to_s
          search_criteria.find do |value|
            return value[key] if value.is_a?(Hash) && value.key?(key)
          end
        end

        def has_criterion?(key)
          key = key.to_s
          search_criteria.any? do |value|
            return true if value.is_a?(Hash) && value.key?(key)
          end
        end

        def search_criteria_keys
          search_criteria.each_with_object([]) do |criterion, keys|
            keys.concat(criterion.keys) if criterion.is_a?(Hash)
          end
        end
      end
    end
  end
end
