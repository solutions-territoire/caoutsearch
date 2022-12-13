# frozen_string_literal: true

require "webmock"
require "uri"

module Caoutsearch
  module Testing
    module MockRequests
      def stub_elasticsearch_request(verb, pattern)
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

      def stub_elasticsearch_batching_requests(index_name, hits = [], batch_size: 1000)
        pid_id = SecureRandom.base64

        stub_elasticsearch_request(:post, "samples/_pit?keep_alive=1m")
          .to_return_json(body: {id: pid_id})

        stub_elasticsearch_request(:delete, "_pit")
          .with(body: {id: pid_id})
          .to_return_json(body: {succeed: true})

        search_request = stub_elasticsearch_request(:post, "_search")
          .with { |request| request.body.include?(pid_id) }

        if hits.any?
          hits.each_slice(batch_size).each_with_index do |slice, index|
            if index.zero?
              search_request.to_return_json(body: {
                hits: {
                  total: {value: hits.size},
                  hits: slice
                }
              })
            else
              search_request.to_return_json(body: {
                hits: {
                  total: {value: slice.size, relation: "gte"},
                  hits: slice
                }
              })
            end
          end
        end

        search_request
      end
    end
  end
end
