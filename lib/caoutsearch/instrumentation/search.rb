# frozen_string_literal: true

module Caoutsearch
  module Instrumentation
    class Search < Base
      def search(event)
        log_request("Search", event, format: log_request_format)
        log_response("Search", event)
      end

      def scroll_search(event)
        log_request("Search", event, format: log_request_format)
        log_response("Search", event) do |message|
          payload = event.payload
          message += ", progress: #{payload[:progress]} / #{payload[:total]}"
          message
        end
      end

      def scroll(event)
        log_request("Scroll", event, format: "truncated")
        log_response("Scroll", event) do |message|
          payload = event.payload
          message += ", progress: #{payload[:progress]} / #{payload[:total]}"
          message
        end
      end

      def delete(event)
        log_request("Delete", event, format: log_request_format)
        log_response("Delete", event)
      end

      private

      def log_request_format
        Caoutsearch.instrumentation_options[:search]
      end
    end
  end
end
