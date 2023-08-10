# frozen_string_literal: true

require "webmock"
require "uri"

module Caoutsearch
  module Testing
    module MockRequests
      def stub_elasticsearch_request(verb, pattern)
        stub_elasticsearch_validation_request

        case pattern
        when String
          pattern = URI.join(elasticsearch_client_host, pattern).to_s
        when Regexp
          pattern = URI.join(elasticsearch_client_host, pattern.source).to_s
          pattern = Regexp.new(pattern)
        else
          raise TypeError, "wrong type received for URL pattern"
        end

        stub_request(verb, pattern)
      end

      def stub_elasticsearch_search_request(index_name, hits, sources: true, total: nil)
        hits = hits.map.each_with_index do |item, index|
          hit = {}
          hit = item if item.is_a?(Hash)
          hit = yield(item) if block_given?
          hit["_index"] ||= index_name
          hit["_id"] ||= item.respond_to?(:id) ? item.id.to_s : (index + 1).to_s
          hit["_score"] ||= 1
          hit["_source"] ||= (sources && item.respond_to?(:as_indexed_json)) ? item.as_indexed_json : {}
          hit
        end

        total ||= hits.size
        total = {"value" => total} if total.is_a?(Numeric)

        stub_elasticsearch_request(:post, "#{index_name}/_search").to_return_json(body: {
          "took" => 10,
          "hits" => {
            "total" => total,
            "max_score" => hits.max { |hit| hit["_score"] },
            "hits" => hits
          }
        })
      end

      def stub_elasticsearch_reindex_request(index_name)
        stub_elasticsearch_request(:post, "#{index_name}/_bulk").to_return_json(body: {
          "took" => 100,
          "items" => [],
          "errors" => false
        })

        stub_elasticsearch_request(:post, "#{index_name}/_refresh").to_return_json(body: {
          "_shards" => {
            "total" => 1,
            "failed" => 0,
            "successful" => 1
          }
        })
      end

      def stub_elasticsearch_batching_requests(index_name, hits = [], keep_alive: "1m", batch_size: 1000)
        pid_id = SecureRandom.base64

        stub_elasticsearch_request(:post, "#{index_name}/_pit?keep_alive=#{keep_alive}")
          .to_return_json(body: {id: pid_id})

        stub_elasticsearch_request(:delete, "_pit")
          .with(body: {id: pid_id})
          .to_return_json(body: {succeed: true})

        search_request = stub_elasticsearch_request(:post, "_search")
          .with { |request| request.body.include?(pid_id) }

        hits.each_slice(batch_size).each_with_index do |slice, index|
          total = index.zero? ? {value: hits.size} : {value: slice.size, relation: "gte"}

          search_request.to_return_json(body: {
            hits: {total: total, hits: slice},
            pit_id: pid_id
          })
        end

        search_request
      end

      private

      def elasticsearch_client_host
        @client_host ||= begin
          transport = Caoutsearch.client.transport
          transport.__full_url(transport.hosts[0])
        end
      end

      # Elasticsearch::Client is verifying the connection to ES when calling
      # the first request on the client.
      #
      # Prior to version 8.9, it sent a request to "/" before the first request
      # and match the the "X-Elastic-Product" header and version returned.
      #
      # Since 8.9, it matches only the header on the first emitted request.
      # Because we cannot we cannot edit all the responses headers configured
      # after calling `stub_elasticsearch_request`, we better have to
      # call the stubbed request to '/' before any request.
      #
      def stub_elasticsearch_validation_request
        @stubbed_elasticsearch_validation_request ||= begin
          root_url = URI.join(elasticsearch_client_host, "/").to_s
          body = +MultiJson.dump({version: {number: Elasticsearch::VERSION}})

          stubbed_request = stub_request(:get, root_url).to_return(
            headers: {"Content-Type" => "application/json", "X-Elastic-Product" => "Elasticsearch"},
            status: 200,
            body: body
          )

          if Gem::Version.new(Elasticsearch::VERSION) >= Gem::Version.new("8.9.0")
            Caoutsearch.client.perform_request("GET", "/")
          end

          stubbed_request
        end
      end
    end
  end
end
