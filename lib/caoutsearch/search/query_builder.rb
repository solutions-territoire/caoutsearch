# frozen_string_literal: true

module Caoutsearch
  module Search
    module QueryBuilder
      extend ActiveSupport::Concern
      include QueryBuilder::Aggregations
      include QueryBuilder::Contexts

      def build
        reset_variable(:@elasticsearch_query)
        reset_variable(:@nested_queries)

        run_callbacks :build do
          build_prepend_hash
          build_search_criteria
          build_contexts
          build_defaults
          build_limits
          build_orders
          build_aggregations
          build_suggestions
          build_fields
          build_source
          build_total_hits_tracking
          build_append_hash
        end

        elasticsearch_query.clean
        elasticsearch_query
      end

      private

      def build_search_criteria
        search_by(search_criteria)
      end

      def build_defaults
        keys = search_criteria_keys.map(&:to_s)

        config[:defaults].each do |key, item|
          instance_exec(&item.block) unless keys.include?(key.to_s)
        end
      end

      def build_limits
        elasticsearch_query[:size] = current_limit.to_i if @current_page || @current_limit
        elasticsearch_query[:from] = current_offset if @current_page || @current_offset
      end

      def build_orders
        return if current_limit.zero?

        order_by(current_order || :default)
      end

      def build_suggestions
        suggest_with(*current_suggestions) if current_suggestions
      end

      def build_fields
        elasticsearch_query[:fields] = current_fields.map(&:to_s) if current_fields
      end

      def build_source
        elasticsearch_query[:_source] = current_source unless current_source.nil?
      end

      def build_total_hits_tracking
        elasticsearch_query[:track_total_hits] = @track_total_hits if @track_total_hits
      end

      def build_prepend_hash
        elasticsearch_query.merge!(@prepend_hash) if @prepend_hash
      end

      def build_append_hash
        elasticsearch_query.merge!(@append_hash) if @append_hash
      end
    end
  end
end
