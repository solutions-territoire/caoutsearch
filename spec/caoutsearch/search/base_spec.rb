# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::Base do
  before do
    stub_search_class("SampleSearch") do
      filter :tag
    end
  end

  it "instantiates a search" do
    expect(SampleSearch.new).to be_a(described_class)
  end
end
