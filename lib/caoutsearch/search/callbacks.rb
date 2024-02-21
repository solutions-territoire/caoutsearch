# frozen_string_literal: true

module Caoutsearch
  module Search
    module Callbacks
      extend ActiveSupport::Concern
      include ActiveSupport::Callbacks

      included do
        define_callbacks :build
      end

      class_methods do
        def before_build(...)
          set_callback(:build, :before, ...)
        end

        def after_build(...)
          set_callback(:build, :after, ...)
        end

        def around_build(...)
          set_callback(:build, :around, ...)
        end
      end
    end
  end
end
