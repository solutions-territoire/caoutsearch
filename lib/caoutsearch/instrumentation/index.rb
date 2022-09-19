# frozen_string_literal: true

module Caoutsearch
  module Instrumentation
    class Index < Base
      def get(event)
        log_request("Get", event, format: log_request_format)
        log_response("Get", event)
      end

      def index(event)
        log_request("Index", event, format: log_request_format)
        log_response("Index", event)
      end

      def update(event)
        log_request("Update", event, format: log_request_format)
        log_response("Update", event)
      end

      def delete(event)
        log_request("Delete", event, format: log_request_format)
        log_response("Delete", event)
      end

      def bulk(event)
        method = event[:method].to_s.titleize

        log_request("Bulk #{method}", event, format: log_request_format)
        log_response("Bulk #{method}", event, warn_errors: true)
      end

      def reindex(event)
        log_request("Reindex", event, format: log_request_format)
        log_response("Reindex", event, warn_errors: true) do |message|
          payload = event.payload
          request = payload[:request]
          request_size = inspect_json_size(request)

          response = payload[:response]
          response_size = inspect_json_size(response)

          message += ", request size: #{request_size}"
          message += ", response size: #{response_size}"
          message += ", progress: #{payload[:progress]} / #{payload[:total]}"
          message
        end
      end

      private

      def log_request_format
        Caoutsearch.instrumentation_options[:index]
      end
    end
  end
end
