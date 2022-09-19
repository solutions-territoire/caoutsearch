# frozen_string_literal: true

module Caoutsearch
  module Search
    module Search
      module Response
        delegate :empty?, :size, :slice, :[], :to_a, :to_ary, to: :hits
        delegate_missing_to :each

        def response
          load unless @response
          @response
        end

        def took
          response["took"]
        end

        def timed_out
          response["timed_out"]
        end

        def shards
          response["_shards"]
        end

        def hits
          response["hits"]["hits"]
        end

        def max_score
          response["hits"]["max_score"]
        end

        def total_count
          response["hits"]["total"]["value"]
        end

        def total_pages
          (total_count.to_f / current_limit).ceil
        end

        def ids
          hits.pluck("_id")
        end

        def aggregations
          # TODO
        end

        def suggestions
          # TODO
        end

        def records
          model.where(model.primary_key => ids)
        end

        def each(&block)
          return to_enum(:each) { hits.size } unless block

          hits.each(&block)
        end

        def load
          @response = perform_search_query(build.to_h)
          self
        end

        def perform_search_query(query)
          request_payload = {
            index:  index_name,
            body:   query
          }

          instrument(:search) do |event_payload|
            event_payload[:request]  = request_payload
            event_payload[:response] = client.search(request_payload)
          end
        end
      end
    end
  end
end
