# frozen_string_literal: true

module Caoutsearch
  module Search
    module DeleteMethods
      def delete_documents
        request_payload = {
          index: index_name,
          body: build.to_h
        }

        instrument(:delete) do |event_payload|
          event_payload[:request] = request_payload
          event_payload[:response] = client.delete_by_query(request_payload)
        end
      end
    end
  end
end
