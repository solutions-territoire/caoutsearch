# frozen_string_literal: true

module Caoutsearch
  module Index
    module Instrumentation
      extend ActiveSupport::Concern

      def instrument(action, **options, &block)
        ActiveSupport::Notifications.instrument("#{action}.caoutsearch_index", **options, klass: self.class.to_s, &block)
      end

      class_methods do
        def instrument(action, **options, &block)
          ActiveSupport::Notifications.instrument("#{action}.caoutsearch_index", **options, klass: to_s, &block)
        end
      end
    end
  end
end
