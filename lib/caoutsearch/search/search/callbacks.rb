# frozen_string_literal: true

require "active_support/callbacks"

module Caoutsearch
  module Search
    module Search
      module Callbacks
        extend  ActiveSupport::Concern
        include ActiveSupport::Callbacks

        included do
          define_callbacks :build
        end

        class_methods do
          def before_build(*filters, &blk)
            set_callback(:build, :before, *filters, &blk)
          end

          def after_build(*filters, &blk)
            set_callback(:build, :after, *filters, &blk)
          end

          def around_build(*filters, &blk)
            set_callback(:build, :around, *filters, &blk)
          end
        end
      end
    end
  end
end
