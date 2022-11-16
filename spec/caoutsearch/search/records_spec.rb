# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::Records do
  let!(:search) { search_class.new }
  let!(:search_class) { stub_search_class("SampleSearch") }

  let!(:stubbed_request) do
    stub_elasticsearch_search_request("samples", [
      {"_id" => "138", "_source" => {"name" => "Hello World"}},
      {"_id" => "135", "_source" => {"name" => "Hello World"}},
      {"_id" => "137", "_source" => {"name" => "Hello World"}},
      {"_id" => "136", "_source" => {"name" => "Hello World"}}
    ])
  end

  before do
    stub_model_class("Sample")
    (135..138).map { |id| Sample.create(id: id) }
  end

  after do
    Sample.delete_all
  end

  it "returns a relation or records after perform request" do
    records = search.records

    aggregate_failures do
      expect(stubbed_request).to have_been_requested.once
      expect(records).to be_an(ActiveRecord::Relation)
      expect(search.loaded?).to be(true)
    end
  end

  it "returns records in the same order of the hits" do
    records = search.records
    expect(records.map(&:id)).to eq([138, 135, 137, 136])
  end
end
