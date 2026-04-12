# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Filter::Boolean do
  let!(:search_class) do
    stub_search_class("SampleSearch") do
      filter :published, as: :boolean

      self.mappings = {
        properties: {
          published: {type: "boolean"}
        }
      }
    end
  end

  it "builds a query from a boolean value" do
    search = search_class.new.search(published: true)

    expect(search.build).to eq(
      query: {
        bool: {
          filter: [
            term: {published: true}
          ]
        }
      }
    )
  end

  it "builds a query from a truthy value" do
    search = search_class.new.search(published: "true")

    expect(search.build).to eq(
      query: {
        bool: {
          filter: [
            term: {published: true}
          ]
        }
      }
    )
  end

  it "builds a query from a falsy value" do
    search = search_class.new.search(published: "f")

    expect(search.build).to eq(
      query: {
        bool: {
          filter: [
            term: {published: false}
          ]
        }
      }
    )
  end

  it "builds a query from an array of values" do
    search = search_class.new.search(published: ["0", "1", ""])

    expect(search.build).to eq(
      query: {
        bool: {
          filter: [
            terms: {published: [false, true]}
          ]
        }
      }
    )
  end
end
