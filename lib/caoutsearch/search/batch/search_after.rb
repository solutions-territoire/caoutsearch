# frozen_string_literal: true

module Caoutsearch
  module Search
    module Batch
      module SearchAfter
        def search_after(pit: nil, keep_alive: nil, batch_size: 1000, &block)
          if pit
            external_pit = true

            warn(<<~MESSAGE) if keep_alive.nil?
              A `pit` was passed to batch records without a `keep_alive` argument.
              You may need it to extend the PIT on each request.
            MESSAGE
          end

          keep_alive ||= "1m"
          pit ||= open_point_in_time(keep_alive: keep_alive)
          search = per(batch_size).track_total_hits

          request_payload = {
            body: search.build.to_h.merge(
              pit: {
                id: pit,
                keep_alive: keep_alive
              }
            )
          }
          request_payload[:body][:sort] ||= [:_shard_doc]

          total = nil
          progress = 0
          requested_at = nil
          last_response_time = Time.current

          loop do
            requested_at = Time.current

            results = instrument(:search_after, pit: pit) do |event_payload|
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
              if external_pit && progress.zero?
                raise_enhance_message_on_missing_pit(e)
              else
                raise_enhance_message_on_pit_failure(e, keep_alive, requested_at, last_response_time)
              end
            end

            hits = results["hits"]["hits"]
            pit = results["pit_id"]
            break if hits.empty?

            yield hits
            break if progress >= total

            request_payload[:body].tap do |body|
              body[:pit][:id] = pit
              body[:search_after] = hits.last["sort"]
              body.delete(:track_total_hits)
            end
          end
        ensure
          close_point_in_time(pit) if pit && !external_pit
        end

        private

        def raise_enhance_message_on_missing_pit(error)
          raise error.exception "PIT was not found. #{error.message}"
        end

        def raise_enhance_message_on_pit_failure(error, keep_alive, requested_at, last_response_time)
          elapsed = (requested_at - last_response_time).round(1).seconds

          raise error.exception("PIT registered for #{keep_alive}, #{elapsed.inspect} elapsed between. #{error.message}")
        end
      end
    end
  end
end
