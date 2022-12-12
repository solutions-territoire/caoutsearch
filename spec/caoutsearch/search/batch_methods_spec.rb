# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::BatchMethods do
  let(:search) { search_class.new }
  let(:search_class) { stub_search_class("SampleSearch") }
  let(:records) { 12.times.map { Sample.create } }

  let(:hits) do
    [
      {"_id" => records[0].id, "sort" => [records[0].id]},
      {"_id" => records[1].id, "sort" => [records[1].id]},
      {"_id" => records[2].id, "sort" => [records[2].id]},
      {"_id" => records[3].id, "sort" => [records[3].id]},
      {"_id" => records[4].id, "sort" => [records[4].id]},
      {"_id" => records[5].id, "sort" => [records[5].id]},
      {"_id" => records[6].id, "sort" => [records[6].id]},
      {"_id" => records[7].id, "sort" => [records[7].id]},
      {"_id" => records[8].id, "sort" => [records[8].id]},
      {"_id" => records[9].id, "sort" => [records[9].id]},
      {"_id" => records[10].id, "sort" => [records[10].id]},
      {"_id" => records[11].id, "sort" => [records[11].id]}
    ]
  end

  before do
    stub_model_class("Sample")
  end

  def stub_search_after
    stub_elasticsearch_batching_requests("samples")
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[0..9]}})
      .to_return_json(body: {hits: {total: {value: 12}, hits: hits[10..]}})
  end

  def stub_total_count_request
    stub_elasticsearch_search_request("samples", [], sources: false, total: 12)
  end

  describe "#find_each_hit" do
    it "returns an enum without firing any request" do
      expect(search.find_each_hit).to be_a(Enumerator)
    end

    it "yield each hit" do
      stub_search_after
      expect { |b| search.find_each_hit(&b) }.to yield_successive_args(*hits)
    end

    it "returns enum size with a single request" do
      stub_total_count_request
      expect(search.find_each_hit.size).to eq(12)
    end
  end

  describe "#find_each_record" do
    it "returns an enum without block" do
      expect(search.find_each_record).to be_a(Enumerator)
    end

    it "yield each record" do
      stub_search_after
      expect { |b| search.find_each_record(&b) }.to yield_successive_args(*records)
    end

    it "returns enum size with a single request" do
      stub_total_count_request
      expect(search.find_each_record.size).to eq(12)
    end
  end

  describe "#find_hits_in_batches" do
    it "returns an enum without block" do
      expect(search.find_hits_in_batches).to be_a(Enumerator)
    end

    it "yield batches of hits" do
      stub_search_after
      expect { |b| search.find_hits_in_batches(&b) }.to yield_successive_args(hits[0..9], hits[10..])
    end

    it "returns enum size with a single request" do
      stub_total_count_request
      expect(search.find_hits_in_batches.size).to eq(2)
    end
  end

  describe "#find_records_in_batches" do
    it "returns an enum without block" do
      expect(search.find_records_in_batches).to be_a(Enumerator)
    end

    it "yield batches of relations of records" do
      stub_search_after
      expect { |b| search.find_records_in_batches(&b) }.to yield_successive_args(
        be_an(ActiveRecord::Relation).and(eq(records[0..9])),
        be_an(ActiveRecord::Relation).and(eq(records[10..]))
      )
    end

    it "returns enum size with a single request" do
      stub_total_count_request
      expect(search.find_hits_in_batches.size).to eq(2)
    end
  end
end
