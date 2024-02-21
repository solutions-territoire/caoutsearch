# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::InternalDSL do
  let!(:search_class) do
    stub_search_class("SampleSearch") do
      self.mappings = {
        properties: {
          tag: {type: "keyword"}
        }
      }

      filter :tag
    end
  end

  it "builds a query base on criteria and mapping" do
    search = search_class.new.search(tag: "discarded")

    expect(search.build.to_h).to eq({
      query: {
        bool: {
          filter: [
            {term: {tag: "discarded"}}
          ]
        }
      }
    })
  end
end
