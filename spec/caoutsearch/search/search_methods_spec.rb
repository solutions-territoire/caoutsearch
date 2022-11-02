# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::SearchMethods do
  let!(:search_class) { stub_search_class("SampleSearch") }

  it "chains search aggregations" do
    search = search_class.new.aggregate(:tags).aggregate(:views)

    expect(search).to have_attributes(current_aggregations: [:tags, :views])
  end

  it "combines multiple aggregations" do
    search = search_class.new.aggregate(:tags, :views)

    expect(search).to have_attributes(current_aggregations: [:tags, :views])
  end

  it "combines multiple aggregations with arguments" do
    search = search_class.new.aggregate(tags: 20)

    expect(search).to have_attributes(current_aggregations: [{tags: 20}])
  end
end
