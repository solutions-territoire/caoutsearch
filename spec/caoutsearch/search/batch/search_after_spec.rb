# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::Batch::SearchAfter do
  let(:search_class) { stub_search_class("SampleSearch") }
  let(:search) { search_class.new }

  let(:hits) do
    12.times.map do |id|
      {"_id" => id, "sort" => [id]}
    end
  end

  let!(:open_pit_request) do
    stub_elasticsearch_request(:post, "samples/_pit?keep_alive=1m")
      .to_return_json(body: {
        id: "pitID-dXdGlONEECFmVrLWk"
      })
  end

  let!(:first_batch_request) do
    stub_elasticsearch_request(:post, "_search")
      .with(body: {
        track_total_hits: true,
        pit: {
          id: "pitID-dXdGlONEECFmVrLWk",
          keep_alive: "1m"
        }
      })
      .to_return_json(body: {
        hits: {
          total: {value: 12},
          hits: hits[0..9]
        }
      })
  end

  let!(:second_batch_request) do
    stub_elasticsearch_request(:post, "_search")
      .with(body: {
        pit: {
          id: "pitID-dXdGlONEECFmVrLWk",
          keep_alive: "1m"
        },
        search_after: [9]
      })
      .to_return_json(body: {
        hits: {
          total: {value: 12},
          hits: hits[10..]
        }
      })
  end

  let!(:close_pit_request) do
    stub_elasticsearch_request(:delete, "_pit")
      .to_return_json(body: {
        succeed: true
      })
  end

  it "performs all expected requests" do
    search.search_after { |_batch| }

    aggregate_failures do
      expect(open_pit_request).to have_been_requested.once
      expect(first_batch_request).to have_been_requested.once
      expect(second_batch_request).to have_been_requested.once
      expect(close_pit_request).to have_been_requested.once
    end
  end

  it "yields batches of hits with progress" do
    expect { |b| search.search_after(&b) }.to yield_successive_args(
      [hits[0..9], {progress: 10, total: 12, pit_id: "pitID-dXdGlONEECFmVrLWk"}],
      [hits[10..], {progress: 12, total: 12, pit_id: "pitID-dXdGlONEECFmVrLWk"}]
    )
  end

  it "raises an enhanced error message when scroll is expired" do
    stub_elasticsearch_request(:post, "_search")
      .with(body: {
        track_total_hits: true,
        pit: {
          id: "pitID-dXdGlONEECFmVrLWk",
          keep_alive: "1m"
        }
      })
      .to_return_json(
        status: 404,
        body: {
          error: {
            root_cause: [{type: "search_context_missing_exception", reason: "No search context found for id [462]"}],
            type: "search_phase_execution_exception",
            reason: "all shards failed",
            phase: "query",
            grouped: true
          }
        }
      )

    expect { search.search_after { |_batch| } }
      .to raise_error(Elastic::Transport::Transport::Errors::NotFound)
      .with_message(/PIT registered for 1m, .* seconds elapsed between. \[404\] {"error"/)
  end
end
