# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::Search::Response do
  let!(:search_class) { stub_search_class("SampleSearch") }

  let!(:stubbed_request) do
    stub_elasticsearch_search_request("samples", [
      {"_id" => "135", "_source" => {"name" => "Hello World"}},
      {"_id" => "137", "_source" => {"name" => "Hello World"}}
    ])
  end

  it "performs a request against ES" do
    search_class.new.load
    expect(stubbed_request).to have_been_requested.once
  end

  it "performs a request against ES when calling `response`" do
    search_class.new.response
    expect(stubbed_request).to have_been_requested.once
  end

  it "performs a request against ES when calling `raw_response`" do
    search_class.new.raw_response
    expect(stubbed_request).to have_been_requested.once
  end

  it "performs a request against ES when calling `to_a`" do
    search_class.new.to_a
    expect(stubbed_request).to have_been_requested.once
  end

  it "returns a response" do
    expect(search_class.new.response).to be_a(Caoutsearch::Response::Response)
  end
end
