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
        def reindex(*properties, **options)
          index_engine_class.reindex(all, *properties, **options) do |records|
            sync_indexation_to_elasticsearch8(records.map(&:id), properties)
          end
        end

        def delete_indexes
          find_in_batches do |batch|
            ids = batch.map(&:id)
            index_engine_class.delete_documents(ids)
            sync_deletion_to_elasticsearch8(ids)
          end
        end

        def delete_index(id)
          index_engine_class.delete_document(id)
          sync_deletion_to_elasticsearch8(id)
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
          self.class.sync_indexation_to_elasticsearch8(id, properties)
        end

        def delete_index
          index_engine_class.new(self).delete_document
          self.class.sync_deletion_to_elasticsearch8(id)
        end
      end
    end
  end
end
