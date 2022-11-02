# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::Response do
  let!(:search)       { search_class.new }
  let!(:search_class) { stub_search_class("SampleSearch") }

  let!(:stubbed_request) do
    stub_elasticsearch_search_request("samples", [
      {"_id" => "135", "_source" => {"name" => "Hello World"}},
      {"_id" => "137", "_source" => {"name" => "Hello World"}}
    ])
  end

  it { expect(search.response).to be_a(Caoutsearch::Response::Response) }
  it { expect(search.raw_response).to be_a(Elasticsearch::API::Response) }
  it { expect(search.hits).to be_a(Hashie::Array) }
  it { expect(search.to_a).to be_an(Array) }
  it { expect(search.aggregations).to be_an(Caoutsearch::Response::Aggregations) }
  it { expect(search.suggestions).to be_an(Caoutsearch::Response::Suggestions) }

  it { expect { search.response }.to change(search, :loaded?).to(true) }
  it { expect { search.raw_response }.to change(search, :loaded?).to(true) }
  it { expect { search.hits }.to change(search, :loaded?).to(true) }
  it { expect { search.to_a }.to change(search, :loaded?).to(true) }
  it { expect { search.aggregations }.to change(search, :loaded?).to(true) }
  it { expect { search.suggestions }.to change(search, :loaded?).to(true) }

  it "performs a request when calling `response`" do
    search.response
    expect(stubbed_request).to have_been_requested.once
  end

  it "performs a request when calling `raw_response`" do
    search.raw_response
    expect(stubbed_request).to have_been_requested.once
  end

  it "performs a request when calling `hits`" do
    search.hits
    expect(stubbed_request).to have_been_requested.once
  end

  it "performs a request when calling `to_a`" do
    search.to_a
    expect(stubbed_request).to have_been_requested.once
  end

  it "performs a request when calling `aggregations`" do
    search.aggregations
    expect(stubbed_request).to have_been_requested.once
  end

  it "performs a request when calling `suggestions`" do
    search.suggestions
    expect(stubbed_request).to have_been_requested.once
  end
end
