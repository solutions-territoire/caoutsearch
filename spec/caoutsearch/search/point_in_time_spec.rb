# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::PointInTime do
  let(:search_class) { stub_search_class("SampleSearch") }
  let(:search) { search_class.new }

  it "opens a PIT" do
    stubbed_request = stub_elasticsearch_request(:post, "samples/_pit?keep_alive=1m")
      .to_return_json(body: {id: "pitID-dXdGlONEECFmVrLWk"})

    aggregate_failures do
      expect(search.open_point_in_time).to eq("pitID-dXdGlONEECFmVrLWk")
      expect(stubbed_request).to have_been_requested.once
    end
  end

  it "close a PIT" do
    stubbed_request = stub_elasticsearch_request(:delete, "_pit")
      .with(body: {id: "pitID-dXdGlONEECFmVrLWk"})
      .to_return_json(body: {succeed: true, num_freed: 5})

    aggregate_failures do
      expect(search.close_point_in_time("pitID-dXdGlONEECFmVrLWk")).to eq({"succeed" => true, "num_freed" => 5})
      expect(stubbed_request).to have_been_requested.once
    end
  end

  it "calculates the number of opened PIT" do
    stubbed_request = stub_elasticsearch_request(:get, "samples/_stats/search,shard_stats")
      .to_return_json(body: {
        _all: {
          primaries: {
            shard_stats: {total_count: 5},
            search: {open_contexts: 3}
          },
          total: {
            shard_stats: {total_count: 15},
            search: {open_contexts: 10}
          }
        }
      })

    aggregate_failures do
      expect(search.opened_points_in_time).to eq(2)
      expect(stubbed_request).to have_been_requested.once
    end
  end
end
