# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::BatchMethods do
  before do
    stub_model_class("Sample")
  end

  let(:search) { search_class.new }
  let(:search_class) { stub_search_class("SampleSearch") }
  let(:records) { 12.times.map { Sample.create }.shuffle }

  let!(:requests) do
    ids = records.map(&:id)

    [
      stub_elasticsearch_request(
        :post, "samples/_pit?keep_alive=1m",
        {id: "pitID-dXdGlONEECFmVrLWk"}
      ),
      stub_elasticsearch_request(
        :post, "_search",
        {
          "hits" => {
            "total" => {"value" => 12},
            "hits" => [
              {"_id" => ids[0], :sort => [ids[0]]},
              {"_id" => ids[1], :sort => [ids[1]]},
              {"_id" => ids[2], :sort => [ids[2]]},
              {"_id" => ids[3], :sort => [ids[3]]},
              {"_id" => ids[4], :sort => [ids[4]]},
              {"_id" => ids[5], :sort => [ids[5]]},
              {"_id" => ids[6], :sort => [ids[6]]},
              {"_id" => ids[7], :sort => [ids[7]]},
              {"_id" => ids[8], :sort => [ids[8]]},
              {"_id" => ids[9], :sort => [ids[9]]}
            ]
          }
        }
      ).with(
        body: {
          track_total_hits: true,
          pit: {
            id: "pitID-dXdGlONEECFmVrLWk",
            keep_alive: "1m"
          }
        }
      ),
      stub_elasticsearch_request(
        :post, "_search",
        {
          "hits" => {
            "total" => {"value" => 12},
            "hits" => [
              {"_id" => ids[10], :sort => [ids[10]]},
              {"_id" => ids[11], :sort => [ids[11]]}
            ]
          }
        }
      ).with(
        body: {
          pit: {
            id: "pitID-dXdGlONEECFmVrLWk",
            keep_alive: "1m"
          },
          search_after: [ids[9]]
        }
      ),
      stub_elasticsearch_request(
        :delete, "_pit",
        {succeed: true}
      )
    ]
  end

  it "opens a PIT and calls elasticsearch" do
    search.find_hits_in_batches { |batch| batch }

    expect(requests).to all(have_been_requested.once)
  end

  describe "#find_each_record" do
    it "allows to enumerate records" do
      expect(search.find_each_record).to all(be_a(Sample))
    end

    it "returns records in the same order of the hits" do
      expect(search.find_each_record.map(&:id)).to eq(records.map(&:id))
    end
  end

  describe "#find_records_in_batches" do
    it "allows to enumerate batches of records" do
      aggregate_failures do
        expect(search.find_records_in_batches).to all(be_a(ActiveRecord::Relation))
        expect(search.find_records_in_batches.to_a.flatten).to all(be_a(Sample))
      end
    end

    it "returns records in the same order of the hits" do
      expect(search.find_records_in_batches.to_a.flatten.map(&:id)).to eq(records.map(&:id))
    end
  end

  describe "#find_hits_in_batches" do
    it "allows to enumerate batches of hits" do
      aggregate_failures do
        expect(search.find_hits_in_batches).to all(be_a(Array))
        expect(search.find_hits_in_batches.to_a.flatten).to all(be_a(Hash))
      end
    end

    it "returns records in the same order of the hits" do
      expect(search.find_hits_in_batches.to_a.flatten.map { |doc| doc["_id"] }).to eq(records.map(&:id))
    end
  end
end
