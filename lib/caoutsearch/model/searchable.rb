# frozen_string_literal: true

module Caoutsearch
  module Model
    module Searchable
      extend ActiveSupport::Concern

      included do
        class_attribute :search_engine_class
      end

      class_methods do
        def search_with(search_class)
          self.search_engine_class = search_class

          extend ClassMethods
        end
      end

      module ClassMethods
        def search_engine
          search_engine_class.new
        end

        def search(...)
          search_engine_class.new.search(...)
        end
      end
    end
  end
end
