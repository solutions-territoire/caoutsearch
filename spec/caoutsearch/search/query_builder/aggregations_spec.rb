# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::QueryBuilder::Aggregations do
  let!(:search_class) do
    stub_search_class("SampleSearch") do
      has_aggregation :view_count, sum: {field: :view_count}
      has_aggregation :tags,
        filter: {term: {published: true}},
        aggs: {
          published: {terms: {field: :tags, size: 10}}
        }

      has_aggregation :popular_tags_since do |date|
        query.aggregations[:popular_tags_since] = {
          filter: {range: {publication_date: {gte: date.to_s}}},
          aggs: {
            published: {terms: {field: :tags, size: 20}}
          }
        }
      end
    end
  end

  it "builds simple aggregations" do
    search = search_class.new.aggregate(:view_count)

    expect(search.build).to eq(
      aggregations: {
        view_count: {
          sum: {field: :view_count}
        }
      }
    )
  end

  it "builds more complex aggregations" do
    search = search_class.new.aggregate(:tags)

    expect(search.build).to eq(
      aggregations: {
        tags: {
          filter: {term: {published: true}},
          aggs: {
            published: {terms: {field: :tags, size: 10}}
          }
        }
      }
    )
  end

  it "builds aggregations with arguments" do
    search = search_class.new.aggregate(popular_tags_since: "2022-10-11")

    expect(search.build).to eq(
      aggregations: {
        popular_tags_since: {
          filter: {range: {publication_date: {gte: "2022-10-11"}}},
          aggs: {
            published: {terms: {field: :tags, size: 20}}
          }
        }
      }
    )
  end
end
