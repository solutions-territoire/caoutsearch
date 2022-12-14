# frozen_string_literal: true

module Caoutsearch
  module Search
    module Batch
      module SearchAfter
        def search_after(keep_alive: "1m", batch_size: 1000, &block)
          pit_id = open_point_in_time(keep_alive: keep_alive)
          search = per(batch_size).track_total_hits

          request_payload = {
            body: search.build.to_h.merge(
              pit: {
                id: pit_id,
                keep_alive: keep_alive
              }
            )
          }

          total = nil
          progress = 0
          requested_at = nil
          last_response_time = Time.current

          loop do
            requested_at = Time.current

            results = instrument(:search_after, pit: pit_id) do |event_payload|
              response = client.search(request_payload)
              last_response_time = Time.current

              total ||= response["hits"]["total"]["value"]
              progress += response["hits"]["hits"].size

              event_payload[:request] = request_payload
              event_payload[:response] = response
              event_payload[:total] = total
              event_payload[:progress] = progress

              response
            rescue Elastic::Transport::Transport::Errors::NotFound => e
              raise_enhance_message_when_pit_failed(e, keep_alive, requested_at, last_response_time)
            end

            hits = results["hits"]["hits"]
            pit_id = results["pit_id"]
            break if hits.empty?

            yield hits
            break if progress >= total

            request_payload[:body].tap do |body|
              body[:pit][:id] = pit_id
              body[:search_after] = hits.last["sort"]
              body.delete(:track_total_hits)
            end
          end
        ensure
          close_point_in_time(pit_id) if pit_id
        end

        def raise_enhance_message_when_pit_failed(error, keep_alive, requested_at, last_response_time)
          elapsed = (requested_at - last_response_time).round(1).seconds

          raise error.exception("PIT registered for #{keep_alive}, #{elapsed.inspect} elapsed between. #{error.message}")
        end
      end
    end
  end
end
