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
          root_url       = URI.join(host, "/").to_s
          body           = +MultiJson.dump({version: {number: "8.4.1"}})
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

      def stub_elasticsearch_search_request(index, hits)
        hits = hits.map.each_with_index do |hit, index|
          hit = yield(hit) if block_given?
          hit["_index"] ||= index
          hit["_id"] ||= (index + 1).to_s
          hit["_score"] ||= 1
          hit["_source"] ||= {}
          hit
        end

        stub_elasticsearch_request(:post, "#{index}/_search", {
          "took" => 10,
          "hits" => {
            "total" => {"value" => hits.size},
            "max_score" => hits.max { |hit| hit["_score"] },
            "hits" => hits
          }
        })
      end
    end
  end
end
