# frozen_string_literal: true

module Caoutsearch
  module Search
    module PointInTime
      def open_point_in_time(index: index_name, keep_alive: "1m")
        results = client.open_point_in_time(index: index, keep_alive: keep_alive)
        results["id"]
      end

      def close_point_in_time(pit_id)
        results = client.close_point_in_time(body: {id: pit_id})
        results.body
      rescue ::Elastic::Transport::Transport::Errors::NotFound
        # We dont care if the PIT ID is already expired
      end

      def opened_points_in_time
        results = client.indices.stats(index: index_name, metric: "search,shard_stats")

        open_contexts = results.dig("_all", "total", "search", "open_contexts")
        number_of_shards = results.dig("_all", "primaries", "shard_stats", "total_count")

        open_contexts / number_of_shards
      end
    end
  end
end
