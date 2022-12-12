# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::Batch::Scroll do
  let(:search_class) { stub_search_class("SampleSearch") }
  let(:search) { search_class.new }

  let(:hits) do
    12.times.map do |i|
      {"_id" => i}
    end
  end

  let!(:first_scroll_request) do
    stub_elasticsearch_request(:post, "samples/_search?scroll=1h").to_return_json(body: {
      _scroll_id: "dXdGlONEECFmVrLWk",
      hits: {
        total: {value: 12},
        hits: hits[0..9]
      }
    })
  end

  let!(:second_scroll_request) do
    stub_elasticsearch_request(:get, "/_search/scroll/dXdGlONEECFmVrLWk?scroll=1h").to_return_json(body: {
      hits: {
        total: {value: 12},
        hits: hits[10..]
      }
    })
  end

  let!(:close_scroll_request) do
    stub_elasticsearch_request(:delete, "_search/scroll/dXdGlONEECFmVrLWk").to_return_json(body: {
      succeed: true
    })
  end

  it "performs all requests" do
    search.scroll { |batch| batch }

    aggregate_failures do
      expect(first_scroll_request).to have_been_requested.once
      expect(second_scroll_request).to have_been_requested.once
      expect(close_scroll_request).to have_been_requested.once
    end
  end

  it "yields batches of hits with progress" do
    expect { |b| search.scroll(&b) }.to yield_successive_args(
      [hits[0..9], {progress: 10, total: 12, scroll_id: "dXdGlONEECFmVrLWk"}],
      [hits[10..], {progress: 12, total: 12, scroll_id: "dXdGlONEECFmVrLWk"}]
    )
  end

  it "raises an enhanced error message when scroll is expired" do
    stub_elasticsearch_request(:get, "/_search/scroll/dXdGlONEECFmVrLWk?scroll=1h").to_return_json(
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

    expect { search.scroll.map { |batch| batch } }
      .to raise_error(Elastic::Transport::Transport::Errors::NotFound)
      .with_message(/Scroll registered for 1h, .* seconds elapsed between. \[404\] {"error"/)
  end
end
