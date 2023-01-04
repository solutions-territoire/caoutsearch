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

  it "opens a PIT, performs search requests and closes the PIT" do
    stubbed_open_pit = stub_elasticsearch_request(:post, "samples/_pit?keep_alive=1m")
      .to_return_json(body: {id: "94GY/RZnrjmaRD1vx6qM7w"})

    stubbed_first_search = stub_elasticsearch_request(:post, "_search")
      .with(body: {track_total_hits: true, size: 10, pit: {id: "94GY/RZnrjmaRD1vx6qM7w", keep_alive: "1m"}, sort: ["_shard_doc"]})
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[0..9]}, pit_id: "94GY/RZnrjmaRD1vx6qM7w"})

    stubbed_second_search = stub_elasticsearch_request(:post, "_search")
      .with(body: {size: 10, pit: {id: "94GY/RZnrjmaRD1vx6qM7w", keep_alive: "1m"}, sort: ["_shard_doc"], search_after: [9]})
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[10..]}, pit_id: "94GY/RZnrjmaRD1vx6qM7w"})

    stubbed_close_pit = stub_elasticsearch_request(:delete, "_pit")
      .with(body: {id: "94GY/RZnrjmaRD1vx6qM7w"})
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
      .to_return_json(body: {id: "94GY/RZnrjmaRD1vx6qM7w"})

    stubbed_first_search = stub_elasticsearch_request(:post, "_search")
      .with(body: {track_total_hits: true, size: 10, pit: {id: "94GY/RZnrjmaRD1vx6qM7w", keep_alive: "1m"}, sort: ["_shard_doc"]})
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[0..9]}, pit_id: "ikYT/9bwfqz+vvCIHVfkkg"})

    stubbed_second_search = stub_elasticsearch_request(:post, "_search")
      .with(body: {size: 10, pit: {id: "ikYT/9bwfqz+vvCIHVfkkg", keep_alive: "1m"}, sort: ["_shard_doc"], search_after: [9]})
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[10..]}, pit_id: "TlNcKTPu+EwTBIjBwE7TQQ"})

    stubbed_close_pit = stub_elasticsearch_request(:delete, "_pit")
      .with(body: {id: "TlNcKTPu+EwTBIjBwE7TQQ"})
      .to_return_json(body: {succeed: true})

    search.search_after(batch_size: 10) { |_batch| }

    aggregate_failures do
      expect(stubbed_open_pit).to have_been_requested.once
      expect(stubbed_first_search).to have_been_requested.once
      expect(stubbed_second_search).to have_been_requested.once
      expect(stubbed_close_pit).to have_been_requested.once
    end
  end

  it "raises an enhanced error message when scroll is expired" do
    stub_elasticsearch_request(:post, "samples/_pit?keep_alive=1m")
      .to_return_json(body: {id: "94GY/RZnrjmaRD1vx6qM7w"})

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
      .to_return_json(body: {id: "94GY/RZnrjmaRD1vx6qM7w"})

    stub_elasticsearch_request(:post, "_search")
      .to_return_json(status: 404, body: {error: {type: "search_phase_execution_exception"}})

    stubbed_close_pit = stub_elasticsearch_request(:delete, "_pit")
      .with(body: {id: "94GY/RZnrjmaRD1vx6qM7w"})
      .to_return_json(body: {succeed: true})

    begin
      search.search_after { |_batch| }
    rescue Elastic::Transport::Transport::Errors::NotFound
    end

    expect(stubbed_close_pit).to have_been_requested.once
  end

  it "yields batches of hits" do
    stub_elasticsearch_request(:post, "samples/_pit?keep_alive=1m")
      .to_return_json(body: {id: "94GY/RZnrjmaRD1vx6qM7w"})

    stub_elasticsearch_request(:post, "_search")
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[0..9]}, pit_id: "94GY/RZnrjmaRD1vx6qM7w"})
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[10..]}, pit_id: "94GY/RZnrjmaRD1vx6qM7w"})

    stub_elasticsearch_request(:delete, "_pit")
      .to_return_json(body: {succeed: true})

    expect { |b| search.search_after(batch_size: 10, &b) }.to yield_successive_args(
      hits[0..9],
      hits[10..]
    )
  end
end
