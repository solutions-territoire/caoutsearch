# frozen_string_literal: true

require "webmock"
require "uri"

module Caoutsearch
  module Testing
    module MockRequests
      def stub_elasticsearch_request(verb, pattern, results = nil, status = 200)
        transport = Caoutsearch.client.transport
        host = transport.__full_url(transport.hosts[0])

        # Elasticsearch::Client is verify the connection
        #
        unless @subbed_verify
          root_url = URI.join(host, "/").to_s
          body = +MultiJson.dump({version: {number: "8.4.1"}})
          @subbed_verify = stub_request(:get, root_url).to_return(
            headers: {"Content-Type" => "application/json", "X-Elastic-Product" => "Elasticsearch"},
            status: 200,
            body: body
          )
        end

        case pattern
        when String
          pattern = URI.join(host, pattern).to_s
        when Regexp
          pattern = URI.join(host, pattern.source).to_s
          pattern = Regexp.new(pattern)
        else
          raise TypeError, "wrong type received for URL pattern"
        end

        # The + sign before the body string make a mutable string.
        # ElasticsearchTransport requires it:
        # See https://github.com/elastic/elasticsearch-ruby/issues/726
        #
        results_body = +(results ? JSON.dump(results) : "")

        stub_request(verb, pattern).to_return(
          headers: {"Content-Type" => "application/json"},
          status: status,
          body: results_body
        )
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

        stub_elasticsearch_request(:post, "#{index_name}/_search", {
          "took" => 10,
          "hits" => {
            "total" => total,
            "max_score" => hits.max { |hit| hit["_score"] },
            "hits" => hits
          }
        })
      end

      def stub_elasticsearch_reindex_request(index_name)
        stub_elasticsearch_request(:post, "#{index_name}/_bulk", {
          "took" => 100,
          "items" => [],
          "errors" => false
        })

        stub_elasticsearch_request(:post, "#{index_name}/_refresh", {
          "_shards" => {
            "total" => 1,
            "failed" => 0,
            "successful" => 1
          }
        })
      end
    end
  end
end
