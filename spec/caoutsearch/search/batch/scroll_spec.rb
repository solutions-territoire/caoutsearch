# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::Batch::Scroll do
  before do
    stub_model_class("Sample")
  end

  let(:search) { search_class.new }
  let(:search_class) { stub_search_class("SampleSearch") }
  let(:records) { 12.times.map { Sample.create }.shuffle }

  let!(:requests) do
    ids = records.map(&:id)

    [
      stub_elasticsearch_request(
        :post, "samples/_search?scroll=1h",
        {
          "hits" => {
            "total" => {"value" => 12},
            "hits" => [
              {"_id" => ids[0]},
              {"_id" => ids[1]},
              {"_id" => ids[2]},
              {"_id" => ids[3]},
              {"_id" => ids[4]},
              {"_id" => ids[5]},
              {"_id" => ids[6]},
              {"_id" => ids[7]},
              {"_id" => ids[8]},
              {"_id" => ids[9]}
            ]
          },
          "_scroll_id" => "dXdGlONEECFmVrLWk"
        }
      ).with(
        body: {}
      ),
      stub_elasticsearch_request(
        :get, "/_search/scroll/dXdGlONEECFmVrLWk?scroll=1h",
        {
          "hits" => {
            "total" => {"value" => 12},
            "hits" => [
              {"_id" => ids[10]},
              {"_id" => ids[11]}
            ]
          }
        }
      ),
      stub_elasticsearch_request(
        :delete, "_search/scroll/dXdGlONEECFmVrLWk",
        {succeed: true}
      )
    ]
  end

  it "opens a PIT and calls elasticsearch" do
    search.scroll { |batch| batch }

    expect(requests).to all(have_been_requested.once)
  end

  it "allows to enumerate batches of hits" do
    aggregate_failures do
      expect(search.scroll).to all(be_a(Array))
      expect(search.scroll.to_a.flatten).to all(be_a(Hash))
      expect(search.scroll.map { |hits, _progress| hits }.flatten.map { |doc| doc["_id"] }).to eq(records.map(&:id))
    end
  end

  it "returns the progress" do
    expect(search.scroll.map { |_hits, progress| progress }).to eq([
      {progress: 10, total: 12, scroll_id: "dXdGlONEECFmVrLWk"},
      {progress: 12, total: 12, scroll_id: "dXdGlONEECFmVrLWk"}
    ])
  end

  describe "error handling" do
    before do
      stub_elasticsearch_request(
        :get, "/_search/scroll/dXdGlONEECFmVrLWk?scroll=1h",
        {
          error: {
            root_cause: [
              {type: "search_context_missing_exception", reason: "No search context found for id [462]"}
            ],
            type: "search_phase_execution_exception",
            reason: "all shards failed",
            phase: "query", grouped: true,
            failed_shards: [
              {shard: 0, index: "samples", node: "ek-i5JezTR6L-KwqNNjw", reason: {
                type: "search_context_missing_exception", reason: "No search context found for id [462]"
              }}
            ]
          }
        }, 404
      )
    end

    it "raises an enhanced error message when pit is expired" do
      expect { search.scroll.map { |batch| batch } }
        .to raise_error(Elastic::Transport::Transport::Errors::NotFound)
        .with_message(/Scroll registered for 1h, .* seconds elapsed between. \[404\] {"error"/)
    end
  end
end
