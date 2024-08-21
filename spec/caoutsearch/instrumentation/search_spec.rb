# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Instrumentation::Search do
  let!(:search) { search_class.new }
  let!(:search_class) { stub_search_class("SampleSearch") }

  before do
    stub_elasticsearch_search_request("samples", [
      {"_id" => "135", "_source" => {"name" => "Hello World"}},
      {"_id" => "137", "_source" => {"name" => "Hello World"}}
    ])
  end

  context "when setting instrumentation to full" do
    before { Caoutsearch.instrument!(search: "full") }

    it "saves instrumentation options" do
      expect(Caoutsearch.instrumentation_options).to eq({search: "full"})
    end

    it "instruments the search query" do
      pending "TODO"

      expect { search.response }.to match_instrumentation
    end
  end
end
