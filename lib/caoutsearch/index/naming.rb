# frozen_string_literal: true

module Caoutsearch
  module Index
    module Naming
      extend ActiveSupport::Concern

      included do
        delegate :index_name, to: :class
      end

      class_methods do
        def index_name
          @index_name ||= default_index_name
        end

        def index_name=(name)
          @index_name = name
        end

        private

        def default_index_name
          name.gsub(/Index$/, "").tableize.tr("/", "_")
        end
      end
    end
  end
end
