# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::QueryBuilder::Contexts do
  let!(:search_class) do
    stub_search_class("SampleSearch") do
      has_context :public do
        filters << {term: {published: true}}
      end

      has_context :blog do
        filters << {term: {destination: "blog"}}
      end
    end
  end

  it "applies one context to a query" do
    search = search_class.new.context(:public)

    expect(search.build).to eq(
      query: {
        bool: {
          filter: [
            {term: {published: true}}
          ]
        }
      }
    )
  end

  it "builds a query with multiple contexts" do
    search = search_class.new.context(:public, :blog)

    expect(search.build).to eq(
      query: {
        bool: {
          filter: [
            {term: {published: true}},
            {term: {destination: "blog"}}
          ]
        }
      }
    )
  end

  it "ignores missing contexts" do
    search = search_class.new.context(:public, :api)

    expect(search.build).to eq(
      query: {
        bool: {
          filter: [
            {term: {published: true}}
          ]
        }
      }
    )
  end
end
