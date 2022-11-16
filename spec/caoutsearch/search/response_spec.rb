# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::Response do
  let!(:search) { search_class.new }
  let!(:search_class) { stub_search_class("SampleSearch") }

  let!(:stubbed_request) do
    stub_elasticsearch_search_request("samples", [
      {"_id" => "135", "_source" => {"name" => "Hello World"}},
      {"_id" => "137", "_source" => {"name" => "Hello World"}}
    ])
  end

  it "returns response after performing request" do
    response = search.response

    aggregate_failures do
      expect(stubbed_request).to have_been_requested.once
      expect(response).to be_a(Caoutsearch::Response::Response)
      expect(search.loaded?).to be(true)
    end
  end

  it "returns raw_response after performing request" do
    raw_response = search.raw_response

    aggregate_failures do
      expect(stubbed_request).to have_been_requested.once
      expect(raw_response).to be_a(Elasticsearch::API::Response)
      expect(search.loaded?).to be(true)
    end
  end

  it "returns hits after performing request" do
    hits = search.hits

    aggregate_failures do
      expect(stubbed_request).to have_been_requested.once
      expect(hits).to be_a(Hashie::Array)
      expect(search.loaded?).to be(true)
    end
  end

  it "returns ids after performing request" do
    ids = search.ids

    aggregate_failures do
      expect(stubbed_request).to have_been_requested.once
      expect(ids).to eq(%w[135 137])
      expect(search.loaded?).to be(true)
    end
  end

  it "returns an array after performing request" do
    array = search.to_a

    aggregate_failures do
      expect(stubbed_request).to have_been_requested.once
      expect(array).to be_a(Array)
      expect(search.loaded?).to be(true)
    end
  end

  it "returns aggregations after performing request" do
    aggregations = search.aggregations

    aggregate_failures do
      expect(stubbed_request).to have_been_requested.once
      expect(aggregations).to be_an(Caoutsearch::Response::Aggregations)
      expect(search.loaded?).to be(true)
    end
  end

  it "returns suggestions after performing request" do
    suggestions = search.suggestions

    aggregate_failures do
      expect(stubbed_request).to have_been_requested.once
      expect(suggestions).to be_an(Caoutsearch::Response::Suggestions)
      expect(search.loaded?).to be(true)
    end
  end
end
