# frozen_string_literal: true

module Caoutsearch
  module Search
    module InternalDSL
      extend ActiveSupport::Concern

      included do
        # Do to not make:
        #   self.config[:filter][key] = ...
        #
        # Changing only config members will lead to inheritance issue.
        # Instead, make:
        #   self.config = config.deep_dup
        #   self.config[:filter][key] = ...
        #
        class_attribute :config, default: {
          filters: ActiveSupport::HashWithIndifferentAccess.new,
          defaults: ActiveSupport::HashWithIndifferentAccess.new,
          suggestions: ActiveSupport::HashWithIndifferentAccess.new,
          sorts: ActiveSupport::HashWithIndifferentAccess.new
        }

        class_attribute :contexts, instance_accessor: false, default: {}
        class_attribute :aggregations, instance_accessor: false, default: {}
        class_attribute :transformations, instance_accessor: false, default: {}
      end

      class_methods do
        def match_all(&block)
          self.config = config.deep_dup
          config[:match_all] = block
        end

        %w[default].each do |method|
          config_attribute = method.pluralize.to_sym

          define_method method do |name = nil, &block|
            self.config = config.deep_dup

            if name
              config[config_attribute][name] = Caoutsearch::Search::DSL::Item.new(name, &block)
            else
              config[config_attribute][:__undef__] = block
            end
          end
        end

        %w[filter sort suggestion].each do |method|
          config_attribute = method.pluralize.to_sym

          define_method method do |name = nil, **options, &block|
            self.config = config.deep_dup

            if name
              config[config_attribute][name.to_s] = Caoutsearch::Search::DSL::Item.new(name, options, &block)
            else
              config[config_attribute][:__undef__] = block
            end
          end
        end

        def alias_filter(new_name, old_name)
          filter(new_name) { |value| search_by(old_name => value) }
        end

        def alias_sort(new_name, old_name)
          sort(new_name) { |direction| sort_by(old_name, direction) }
        end

        def has_context(name, &block)
          self.contexts = contexts.dup
          contexts[name.to_s] = Caoutsearch::Search::DSL::Item.new(name, &block)
        end

        def has_aggregation(name, definition = {}, &block)
          raise ArgumentError, "has_aggregation accepts Hash definition or block but not both" if block && definition.any?

          self.aggregations = aggregations.dup
          aggregations[name.to_s] = Caoutsearch::Search::DSL::Item.new(name, definition, &block)
        end

        def alias_aggregation(new_name, old_name)
          has_aggregation(new_name) do |*args|
            call_aggregation(old_name, *args)
          end
        end

        def transform_aggregation(name, from: nil, track_total_hits: false, &block)
          name = name.to_s
          dependencies = Array.wrap(from).map(&:to_s)

          raise ArgumentError, "block is missing" unless block

          if aggregations.exclude?(name)
            raise ArgumentError, "aggregation #{name} is missing, you may have to define :requires" if dependencies.empty?

            has_aggregation(name) do |*args|
              track_total_hits! if track_total_hits
              dependencies.each do |dependency|
                call_aggregation(dependency, *args)
              end
            end
          end

          self.transformations = transformations.dup
          transformations[name.to_s] = Caoutsearch::Search::DSL::Item.new(name, {from: from}, &block)
        end
      end
    end
  end
end
