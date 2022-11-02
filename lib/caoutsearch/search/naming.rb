# frozen_string_literal: true

module Caoutsearch
  module Search
    module Naming
      extend ActiveSupport::Concern

      included do
        delegate :model, :model_name, :index_name, to: :class
      end

      class_methods do
        def model
          @model ||= model_name.constantize
        end

        def model_name
          @model_name ||= defaut_model_name
        end

        def model_name=(name)
          @model_name = name
        end

        def index_name
          @index_name ||= default_index_name
        end

        def index_name=(name)
          @index_name = name
        end

        private

        def default_index_name
          name.gsub(/Search$/, "").tableize.tr("/", "_")
        end

        def defaut_model_name
          name.gsub(/Search$/, "")
        end
      end
    end
  end
end
