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
          contexts: ActiveSupport::HashWithIndifferentAccess.new,
          filters: ActiveSupport::HashWithIndifferentAccess.new,
          defaults: ActiveSupport::HashWithIndifferentAccess.new,
          aggregations: ActiveSupport::HashWithIndifferentAccess.new,
          suggestions: ActiveSupport::HashWithIndifferentAccess.new,
          sorts: ActiveSupport::HashWithIndifferentAccess.new
        }
      end

      class_methods do
        def match_all(&block)
          self.config = config.deep_dup
          config[:match_all] = block
        end

        %w[context default].each do |method|
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

        %w[filter aggregation sort suggestion].each do |method|
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

        def alias_aggregation(new_name, old_name)
          aggregation(new_name) { aggregate_with(old_name) }
        end
      end
    end
  end
end
