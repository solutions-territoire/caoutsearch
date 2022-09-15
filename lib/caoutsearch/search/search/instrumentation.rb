# frozen_string_literal: true

module Caoutsearch
  module Search
    module Search
      module Instrumentation
        extend ActiveSupport::Concern

        def instrument(action, **options, &block)
          ActiveSupport::Notifications.instrument("#{action}.caoutsearch_search", **options, klass: self.class.to_s, &block)
        end

        class_methods do
          def instrument(action, **options, &block)
            ActiveSupport::Notifications.instrument("#{action}.caoutsearch_search", **options, klass: to_s, &block)
          end
        end
      end
    end
  end
end
