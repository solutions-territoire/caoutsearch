# frozen_string_literal: true

module Caoutsearch
  module Search
    module Search
      module QueryBuilder
        extend ActiveSupport::Concern

        included do
          include ActiveSupport::Callbacks
          define_callbacks :build
        end

        def build
          run_callbacks :build do
            apply_prepend_hash
            apply_search_criteria
            apply_context
            apply_defaults
            apply_limits
            apply_orders
            apply_aggregations
            apply_suggestions
            apply_fields
            apply_source
            apply_append_hash
          end

          elasticsearch_query.clean
          elasticsearch_query
        end

        def apply_search_criteria
          search_by(search_criteria)
        end

        def apply_context
          return unless current_context

          item = config[:contexts][current_context.to_s]
          instance_exec(&item.block) if item
        end

        def apply_defaults
          keys = search_criteria_keys.map(&:to_s)

          config[:defaults].each do |key, item|
            instance_exec(&item.block) unless keys.include?(key.to_s)
          end
        end

        def apply_limits
          elasticsearch_query[:size] = current_limit.to_i if @current_page || @current_limit
          elasticsearch_query[:from] = current_offset     if @current_page || @current_offset
        end

        def apply_orders
          return if current_limit.zero?

          order_by(current_order || :default)
        end

        def apply_aggregations
          aggregate_with(*current_aggregations) if current_aggregations
        end

        def apply_suggestions
          suggest_with(*current_suggestions) if current_suggestions
        end

        def apply_fields
          elasticsearch_query[:fields] = current_fields.map(&:to_s) if current_fields
        end

        def apply_source
          elasticsearch_query[:_source] = current_source unless current_source.nil?
        end

        def apply_prepend_hash
          elasticsearch_query.merge!(@prepend_hash) if @prepend_hash
        end

        def apply_append_hash
          elasticsearch_query.merge!(@append_hash) if @append_hash
        end
      end
    end
  end
end
