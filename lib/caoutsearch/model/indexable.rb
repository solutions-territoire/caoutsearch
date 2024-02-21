# frozen_string_literal: true

module Caoutsearch
  module Model
    module Indexable
      extend ActiveSupport::Concern

      included do
        class_attribute :index_engine_class
      end

      class_methods do
        def index_with(index_class)
          self.index_engine_class = index_class

          extend ClassMethods
          include InstanceMethods
        end
      end

      module ClassMethods
        def reindex(...)
          index_engine_class.reindex(all, ...)
        end

        def delete_indexes
          find_in_batches do |batch|
            ids = batch.map(&:id)
            index_engine_class.delete_documents(ids)
          end
        end

        def delete_index(id)
          index_engine_class.delete_document(id)
        end
      end

      module InstanceMethods
        def as_indexed_json(*properties)
          index_engine_class.new(self).as_json(*properties)
        end

        def indexed_document
          index_engine_class.new(self).indexed_document
        end

        def update_index(*properties)
          index_engine_class.new(self).update_document(*properties)
        end

        def delete_index
          index_engine_class.new(self).delete_document
        end
      end
    end
  end
end
