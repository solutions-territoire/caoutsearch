# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::Batch::SearchAfter do
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
        :post, "samples/_pit?keep_alive=1m",
        {id: "pitID-dXdGlONEECFmVrLWk"}
      ),
      stub_elasticsearch_request(
        :post, "_search",
        {
          "hits" => {
            "total" => {"value" => 12},
            "hits" => [
              {"_id" => ids[0], :sort => [ids[0]]},
              {"_id" => ids[1], :sort => [ids[1]]},
              {"_id" => ids[2], :sort => [ids[2]]},
              {"_id" => ids[3], :sort => [ids[3]]},
              {"_id" => ids[4], :sort => [ids[4]]},
              {"_id" => ids[5], :sort => [ids[5]]},
              {"_id" => ids[6], :sort => [ids[6]]},
              {"_id" => ids[7], :sort => [ids[7]]},
              {"_id" => ids[8], :sort => [ids[8]]},
              {"_id" => ids[9], :sort => [ids[9]]}
            ]
          }
        }
      ).with(
        body: {
          track_total_hits: true,
          pit: {
            id: "pitID-dXdGlONEECFmVrLWk",
            keep_alive: "1m"
          }
        }
      ),
      stub_elasticsearch_request(
        :post, "_search",
        {
          "hits" => {
            "total" => {"value" => 12},
            "hits" => [
              {"_id" => ids[10], :sort => [ids[10]]},
              {"_id" => ids[11], :sort => [ids[11]]}
            ]
          }
        }
      ).with(
        body: {
          pit: {
            id: "pitID-dXdGlONEECFmVrLWk",
            keep_alive: "1m"
          },
          search_after: [ids[9]]
        }
      ),
      stub_elasticsearch_request(
        :delete, "_pit",
        {succeed: true}
      )
    ]
  end

  it "opens a PIT and calls elasticsearch" do
    search.search_after { |batch| batch }

    expect(requests).to all(have_been_requested.once)
  end

  it "allows to enumerate batches of hits" do
    aggregate_failures do
      expect(search.search_after).to all(be_a(Array))
      expect(search.search_after.to_a.flatten).to all(be_a(Hash))
      expect(search.search_after.map { |hits, _progress| hits }.flatten.map { |doc| doc["_id"] }).to eq(records.map(&:id))
    end
  end

  it "returns the progress" do
    expect(search.search_after.map { |_hits, progress| progress }).to eq([
      {progress: 10, total: 12, pit_id: "pitID-dXdGlONEECFmVrLWk"},
      {progress: 12, total: 12, pit_id: "pitID-dXdGlONEECFmVrLWk"}
    ])
  end

  describe "error handling" do
    before do
      stub_elasticsearch_request(
        :post, "_search",
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
      ).with(
        body: {
          track_total_hits: true,
          pit: {
            id: "pitID-dXdGlONEECFmVrLWk",
            keep_alive: "1m"
          }
        }
      )
    end

    it "raises an enhanced error message when pit is expired" do
      expect { search.search_after.next }
        .to raise_error(Elastic::Transport::Transport::Errors::NotFound)
        .with_message(/PIT registered for 1m, .* seconds elapsed between. \[404\] {"error"/)
    end
  end
end
