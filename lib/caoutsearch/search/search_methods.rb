# frozen_string_literal: true

module Caoutsearch
  module Search
    module SearchMethods
      extend ActiveSupport::Concern

      attr_reader :current_contexts, :current_order, :current_aggregations,
        :current_suggestions, :current_fields, :current_source

      # Public API
      # ------------------------------------------------------------------------
      class_methods do
        delegate :search, :order, :page, :limit, :offset, :aggregate,
          :suggest, :fields, :source, :without_sources, :without_hits,
          :track_total_hits, :prepend, :append,
          to: :new
      end

      def search(...)
        spawn.search!(...)
      end

      def context(...)
        spawn.context!(...)
      end

      def order(...)
        spawn.order!(...)
      end

      def page(...)
        spawn.page!(...)
      end

      def limit(...)
        spawn.limit!(...)
      end
      alias_method :per, :limit

      def offset(...)
        spawn.offset!(...)
      end

      def aggregate(...)
        spawn.aggregate!(...)
      end

      def suggest(...)
        spawn.suggest!(...)
      end

      def fields(...)
        spawn.fields!(...)
      end
      alias_method :returns, :fields

      def source(...)
        spawn.source!(...)
      end
      alias_method :with_sources, :source

      def without_sources
        spawn.source!(false)
      end

      def without_hits
        spawn.source!(false).limit!(0)
      end

      def track_total_hits(...)
        spawn.track_total_hits!(...)
      end

      def prepend(...)
        spawn.prepend!(...)
      end

      def append(...)
        spawn.append!(...)
      end

      def unscope(...)
        spawn.unscope!(...)
      end

      # Setters
      # ------------------------------------------------------------------------
      def search!(*values)
        values = values.flatten.filter_map do |value|
          value = value.stringify_keys if value.is_a?(Hash)
          value
        end

        @search_criteria ||= []
        @search_criteria += values
        self
      end

      def context!(*values)
        @current_contexts ||= []
        @current_contexts += values.flatten
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

      def track_total_hits!(value = true)
        @track_total_hits = value
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

      # rubocop:disable Layout/HashAlignment
      UNSCOPE_KEYS = {
        "search"          => :@search_criteria,
        "search_criteria" => :@search_criteria,
        "limit"           => :@current_limit,
        "per"             => :@current_limit,
        "aggregate"       => :@current_aggregations,
        "aggregations"    => :@current_aggregations,
        "suggest"         => :@current_suggestions,
        "suggestions"     => :@current_suggestions,
        "context"         => :@current_contexts,
        "order"           => :@current_order,
        "page"            => :@current_page,
        "offset"          => :@current_offset,
        "fields"          => :@current_fields,
        "source"          => :@current_source
      }.freeze
      # rubocop:enable Layout/HashAlignment

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
