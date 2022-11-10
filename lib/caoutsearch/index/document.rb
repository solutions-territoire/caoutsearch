# frozen_string_literal: true

module Caoutsearch
  module Index
    module Document
      extend ActiveSupport::Concern

      # Return the indexed document
      #
      #     record = Article.find(1)
      #     ArticleIndex.new(record).indexed_document
      #
      def indexed_document
        request_payload = {
          index: index_name,
          id: record.id
        }

        response = instrument(:get) do |event_payload|
          event_payload[:request] = request_payload
          event_payload[:response] = client.get(request_payload)
        end

        response.body
      end

      # Overwrite or partially update a document
      #
      #     record = Article.find(1)
      #     ArticleIndex.new(record).update_document
      #     ArticleIndex.new(record).update_document(:title, :content)
      #
      def update_document(*keys, index: index_name, refresh: false)
        request_payload = {
          index: index,
          id: id
        }

        if keys.empty?
          request_payload[:body] = as_json

          instrument(:index) do |event_payload|
            event_payload[:request] = request_payload
            event_payload[:response] = client.index(request_payload)
          end
        else
          request_payload[:body] = bulkify(:update, keys)

          instrument(:bulk, method: :update) do |event_payload|
            event_payload[:request] = request_payload
            event_payload[:response] = client.bulk(request_payload)
          end
        end

        refresh_indice(index: index) if refresh
      end

      # Delete the document
      #
      #     record = Article.find(1)
      #     ArticleIndex.new(record).delete_document
      #
      def delete_document(index: index_name, refresh: false)
        self.class.delete_document(record.id, index: index, refresh: refresh)
      end

      class_methods do
        # Delete one document
        #
        #     ArticleIndex.delete_document(1)
        #
        def delete_document(id, index: index_name, refresh: false)
          request_payload = {
            index: index,
            id: id,
            ignore: 404
          }

          instrument(:delete) do |event_payload|
            event_payload[:request] = request_payload
            event_payload[:response] = client.delete(request_payload)
          end

          refresh_indice(index: index) if refresh
        end

        # Delete many documents, using bulk API
        #
        #     ArticleIndex.delete_documents([1, 2, 3])
        #
        def delete_documents(ids, index: index_name, refresh: false)
          request_payload = {
            index: index,
            body: ids.map { |id| {delete: {_id: id}} }
          }

          instrument(:bulk, method: :delete) do |event_payload|
            event_payload[:request] = request_payload
            event_payload[:response] = client.bulk(request_payload)
          end

          refresh_indice(index: index) if refresh
        end
      end
    end
  end
end
