# frozen_string_literal: true

module Caoutsearch
  module Instrumentation
    class Base < ActiveSupport::LogSubscriber
      private

      def log_request(subject, event, format: nil)
        return unless format

        payload  = event.payload
        request  = payload[:request]

        debug do
          title        = color("#{payload[:klass]} #{subject}", GREEN, true)
          request_body = format_request_body(request, format: format)

          message = "  #{title} #{request_body}"
          message = yield(message, payload) if block_given?
          message
        end
      end

      def log_response(subject, event, warn_errors: false)
        payload  = event.payload
        response = payload[:response]
        return unless response

        debug do
          title     = color("#{payload[:klass]} #{subject}", GREEN, true)

          duration  = "#{event.duration.round(1)}ms"
          duration += " / took #{response['took']}ms" if response.key?("took")
          duration  = color("(#{duration})", GREEN, true)

          message  = "  #{title} #{duration}"
          message += " got errors" if response["errors"]
          message  = yield(message, payload) if block_given?

          message
        end

        return unless response["errors"] && warn_errors

        errors = response["items"].select { |k, _| k.values.first["error"] }
        errors.each do |error|
          warn { color(error, RED, true) }
        end
      end

      def format_request_body(body, format: nil)
        case format
        when "amazing_print", "awesome_print"
          body.ai(limit: true, index: false)
        when "full"
          json = JSON.dump(body)
          color(json, BLUE, true)
        when "truncated"
          json = JSON.dump(body).truncate(200, omission: "…}")
          color(json, BLUE, true)
        end
      end

      def inspect_json_size(json)
        ApplicationController.helpers.number_to_human_size(JSON.dump(json).bytesize)
      end
    end
  end
end
