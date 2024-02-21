# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::DeleteMethods do
  let!(:search_class) do
    stub_search_class("SampleSearch") do
      self.mappings = {
        properties: {
          tag: {type: "keyword"}
        }
      }

      filter :tag
    end
  end

  let!(:stubbed_request) do
    stub_elasticsearch_request(:post, "samples/_delete_by_query")
      .with(body: {query: {bool: {filter: [{term: {tag: "discarded"}}]}}})
      .to_return_json(body: {
        "took" => 147,
        "timed_out" => false,
        "total" => 119,
        "deleted" => 119,
        "batches" => 1,
        "noops" => 0,
        "retries" => {},
        "failures" => []
      })
  end

  it "delete all indexed document by query" do
    search = search_class.new.search(tag: "discarded")
    response = search.delete_documents

    aggregate_failures do
      expect(stubbed_request).to have_been_requested.once
      expect(response).to be_a(Elasticsearch::API::Response)
      expect(response.to_h).to include("took" => 147, "total" => 119, "deleted" => 119)
      expect(search.loaded?).to be(false)
    end
  end
end
