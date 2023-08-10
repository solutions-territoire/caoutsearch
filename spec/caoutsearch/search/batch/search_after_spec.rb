# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::Batch::SearchAfter do
  let(:search_class) { stub_search_class("SampleSearch") }
  let(:search) { search_class.new }

  let(:pit_id) { generate_random_pit }

  let(:hits) do
    Array.new(12) do |i|
      {"_id" => i, "sort" => [i]}
    end
  end

  def generate_random_pit
    SecureRandom.base36(664)
  end

  it "opens a PIT, performs search requests and closes the PIT" do
    stubbed_open_pit = stub_elasticsearch_request(:post, "samples/_pit?keep_alive=1m")
      .to_return_json(body: {id: pit_id})

    stubbed_first_search = stub_elasticsearch_request(:post, "_search")
      .with(body: {track_total_hits: true, size: 10, pit: {id: pit_id, keep_alive: "1m"}, sort: ["_shard_doc"]})
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[0..9]}, pit_id: pit_id})

    stubbed_second_search = stub_elasticsearch_request(:post, "_search")
      .with(body: {size: 10, pit: {id: pit_id, keep_alive: "1m"}, sort: ["_shard_doc"], search_after: [9]})
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[10..]}, pit_id: pit_id})

    stubbed_close_pit = stub_elasticsearch_request(:delete, "_pit")
      .with(body: {id: pit_id})
      .to_return_json(body: {succeed: true})

    search.search_after(batch_size: 10) { |_batch| }

    aggregate_failures do
      expect(stubbed_open_pit).to have_been_requested.once
      expect(stubbed_first_search).to have_been_requested.once
      expect(stubbed_second_search).to have_been_requested.once
      expect(stubbed_close_pit).to have_been_requested.once
    end
  end

  it "updates the PIT ID for each requests when it changes" do
    stubbed_open_pit = stub_elasticsearch_request(:post, "samples/_pit?keep_alive=1m")
      .to_return_json(body: {id: pit_id})

    another_pit_id = generate_random_pit
    stubbed_first_search = stub_elasticsearch_request(:post, "_search")
      .with(body: {track_total_hits: true, size: 10, pit: {id: pit_id, keep_alive: "1m"}, sort: ["_shard_doc"]})
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[0..9]}, pit_id: another_pit_id})

    yet_another_pit_id = generate_random_pit
    stubbed_second_search = stub_elasticsearch_request(:post, "_search")
      .with(body: {size: 10, pit: {id: another_pit_id, keep_alive: "1m"}, sort: ["_shard_doc"], search_after: [9]})
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[10..]}, pit_id: yet_another_pit_id})

    stubbed_close_pit = stub_elasticsearch_request(:delete, "_pit")
      .with(body: {id: yet_another_pit_id})
      .to_return_json(body: {succeed: true})

    search.search_after(batch_size: 10) { |_batch| }

    aggregate_failures do
      expect(stubbed_open_pit).to have_been_requested.once
      expect(stubbed_first_search).to have_been_requested.once
      expect(stubbed_second_search).to have_been_requested.once
      expect(stubbed_close_pit).to have_been_requested.once
    end
  end

  it "raises an enhanced error message when PIT has expired" do
    stub_elasticsearch_request(:post, "samples/_pit?keep_alive=1m")
      .to_return_json(body: {id: pit_id})

    stub_elasticsearch_request(:post, "_search")
      .to_return_json(status: 404, body: {error: {type: "search_phase_execution_exception"}})

    stub_elasticsearch_request(:delete, "_pit")
      .to_return_json(body: {succeed: true})

    expect { search.search_after { |_batch| } }
      .to raise_error(Elastic::Transport::Transport::Errors::NotFound)
      .with_message(/PIT registered for 1m, .* seconds elapsed between. \[404\] {"error"/)
  end

  it "closes PIT after when an exception happened" do
    stub_elasticsearch_request(:post, "samples/_pit?keep_alive=1m")
      .to_return_json(body: {id: pit_id})

    stub_elasticsearch_request(:post, "_search")
      .to_return_json(status: 404, body: {error: {type: "search_phase_execution_exception"}})

    stubbed_close_pit = stub_elasticsearch_request(:delete, "_pit")
      .with(body: {id: pit_id})
      .to_return_json(body: {succeed: true})

    begin
      search.search_after { |_batch| }
    rescue Elastic::Transport::Transport::Errors::NotFound
    end

    expect(stubbed_close_pit).to have_been_requested.once
  end

  it "uses the given PIT ID and do not close it" do
    stubbed_search = stub_elasticsearch_request(:post, "_search")
      .with(body: {track_total_hits: true, size: 10, pit: {id: pit_id, keep_alive: "10m"}, sort: ["_shard_doc"]})
      .to_return_json(body: {hits: {total: {value: 5}, hits: hits[0..4]}, pit_id: pit_id})

    search.search_after(batch_size: 10, pit: pit_id, keep_alive: "10m") { |_batch| }

    aggregate_failures do
      expect(stubbed_search).to have_been_requested.once

      expect(WebMock).not_to have_requested(:post, "samples/_pit")
      expect(WebMock).not_to have_requested(:delete, "_pit")
    end
  end

  it "raises an explicit error when PIT ID argument is not found by Elasticsearch" do
    stubbed_search = stub_elasticsearch_request(:post, "_search")
      .to_return_json(status: 404, body: {error: {type: "search_context_missing_exception"}})

    expect {
      search.search_after(pit: pit_id) { |_batch| }
    }
      .to raise_error(Elastic::Transport::Transport::Errors::NotFound)
      .with_message(/PIT was not found. \[404\] {"error"/)
  end

  it "warns about missing keep_alive argument along with PIT ID argument" do
    stubbed_search = stub_elasticsearch_request(:post, "_search")
      .with(body: {track_total_hits: true, size: 10, pit: {id: pit_id, keep_alive: "1m"}, sort: ["_shard_doc"]})
      .to_return_json(body: {hits: {total: {value: 5}, hits: hits[0..4]}, pit_id: pit_id})

    expect {
      search.search_after(batch_size: 10, pit: pit_id) { |_batch| }
    }.to output(
      /A `pit` was passed to batch records without a `keep_alive` argument. You may need it to extend the PIT on each request./
    ).to_stderr
  end

  it "yields batches of hits" do
    stub_elasticsearch_request(:post, "samples/_pit?keep_alive=1m")
      .to_return_json(body: {id: pit_id})

    stub_elasticsearch_request(:post, "_search")
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[0..9]}, pit_id: pit_id})
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[10..]}, pit_id: pit_id})

    stub_elasticsearch_request(:delete, "_pit")
      .to_return_json(body: {succeed: true})

    expect { |b| search.search_after(batch_size: 10, &b) }.to yield_successive_args(
      hits[0..9],
      hits[10..]
    )
  end
end
