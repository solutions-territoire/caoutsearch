# frozen_string_literal: true

module Caoutsearch
  module Search
    module Search
      module ScrollMethods
        def scroll(scroll: "1h", &block)
          return to_enum(scroll, scroll: scroll) unless block

          request_payload = {
            index:  index_name,
            scroll: scroll,
            body:   build.to_h
          }

          total              = 0
          progress           = 0
          requested_at       = nil
          last_response_time = nil

          results = instrument(:scroll_search) do |event_payload|
            response           = client.search(request_payload)
            last_response_time = Time.current

            total     = response["hits"]["total"]["value"]
            progress += response["hits"]["hits"].size

            event_payload[:request]  = request_payload
            event_payload[:response] = response
            event_payload[:total]    = total
            event_payload[:progress] = progress

            response
          end

          scroll_id = results["_scroll_id"]
          hits      = results["hits"]["hits"]

          yield hits, { progress: progress, total: total, scroll_id: scroll_id }

          while progress < total
            request_payload = {
              scroll_id: scroll_id,
              scroll:    scroll
            }

            requested_at = Time.current

            results = instrument(:scroll, scroll: scroll_id) do |event_payload|
              response           = client.scroll(request_payload)
              last_response_time = Time.current

              total     = response["hits"]["total"]["value"]
              progress += response["hits"]["hits"].size

              event_payload[:request]  = request_payload
              event_payload[:response] = response
              event_payload[:total]    = total
              event_payload[:progress] = progress

              response
            rescue Elastic::Transport::Transport::Errors::NotFound => e
              raise_enhance_message_when_scroll_failed(e, scroll, requested_at, last_response_time)
            end

            hits       = results["hits"]["hits"]
            progress  += hits.size

            break if hits.empty?

            yield hits, { progress: progress, total: total, scroll_id: scroll_id }
          end

          total
        ensure
          clear_scroll(scroll_id) if scroll_id
        end

        def clear_scroll(scroll_id)
          client.clear_scroll(scroll_id: scroll_id)
        rescue ::Elastic::Transport::Transport::Errors::NotFound
          # We dont care if the scroll ID is already expired
        end

        def scroll_records_in_batches(**options)
          return to_enum(:scroll_records_in_batches, **options) unless block_given?

          scroll(**options) do |hits|
            ids = hits.map { |doc| doc["_id"] }
            yield model.where(id: ids)
            model.connection.clear_query_cache
          end
        end

        def scroll_records(**options, &block)
          return to_enum(:scroll_records, **options) unless block

          scroll_records_in_batches(**options) do |relation|
            relation.each(&block)
          end
        end

        private

        def raise_enhance_message_when_scroll_failed(error, scroll, requested_at, last_response_time)
          elapsed = (requested_at - last_response_time).round(1).seconds

          raise error.exception("Scroll registered for #{scroll}, #{elapsed.inspect} elapsed between. #{error.message}")
        end
      end
    end
  end
end
