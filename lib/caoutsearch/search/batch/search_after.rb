# frozen_string_literal: true

module Caoutsearch
  module Search
    module Batch
      module SearchAfter
        def search_after(keep_alive: "1m", &block)
          return to_enum(:search_after, keep_alive: keep_alive) unless block

          data = client.open_point_in_time(index: index_name, keep_alive: keep_alive)
          pit_id = data.body["id"]
          sort_values = []
          progress = 0
          total = nil
          requested_at = nil
          last_response_time = Time.current

          request_payload = {
            body: track_total_hits.build.to_h.merge(
              pit: {
                id: pit_id,
                keep_alive: keep_alive
              }
            )
          }

          loop do
            request_payload[:body][:search_after] = sort_values if sort_values.any?

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

            request_payload[:body].reject! { |k| k == :track_total_hits } if request_payload[:body][:track_total_hits]
            hits = results["hits"]["hits"]
            yield hits, {progress: progress, total: total, pit_id: pit_id}
            break if hits.empty? || progress >= total

            sort_values = hits.last["sort"]
          end
        ensure
          clear_pit(pit_id)
        end

        def clear_pit(pit_id)
          client.close_point_in_time(body: {id: pit_id}) if pit_id
        rescue ::Elastic::Transport::Transport::Errors::NotFound
          # We dont care if the PIT ID is already expired
        end

        private

        def raise_enhance_message_when_pit_failed(error, keep_alive, requested_at, last_response_time)
          elapsed = (requested_at - last_response_time).round(1).seconds

          raise error.exception("PIT registered for #{keep_alive}, #{elapsed.inspect} elapsed between. #{error.message}")
        end
      end
    end
  end
end
