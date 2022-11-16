# frozen_string_literal: true

module Caoutsearch
  module Search
    module Response
      delegate :empty?, :size, :slice, :[], :to_a, :to_ary, to: :hits
      delegate_missing_to :each

      def load
        @raw_response = perform_search_query(build.to_h)
        @response = Caoutsearch::Response::Response.new(@raw_response)
        @loaded = true
        self
      end

      def loaded?
        @loaded
      end

      def response
        load unless loaded?
        @response
      end

      def raw_response
        load unless loaded?
        @raw_response
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
        response.dig("hits", "hits")
      end

      def max_score
        response.dig("hits", "max_score")
      end

      def total
        response.dig("hits", "total")
      end

      def total_count
        if !@track_total_hits && (!loaded? || response.dig("hits", "total", "relation") == "gte")
          @total_count ||= spawn.track_total_hits!(true).source!(false).limit!(0).total_count
        else
          response.dig("hits", "total", "value")
        end
      end

      def total_pages
        (total_count.to_f / current_limit).ceil
      end

      def ids
        hits.map { |hit| hit["_id"] }
      end

      def aggregations
        @aggregations ||= Caoutsearch::Response::Aggregations.new(response.aggregations)
      end

      def suggestions
        @aggregations ||= Caoutsearch::Response::Suggestions.new(response.suggest)
      end

      def each(&block)
        return to_enum(:each) { hits.size } unless block

        hits.each(&block)
      end

      def perform_search_query(query)
        request_payload = {
          index: index_name,
          body: query
        }

        instrument(:search) do |event_payload|
          event_payload[:request] = request_payload
          event_payload[:response] = client.search(request_payload)
        end
      end
    end
  end
end
