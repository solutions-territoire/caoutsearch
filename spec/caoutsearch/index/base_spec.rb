# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Index::Base do
  before do
    stub_index_class("SampleIndex") do
      property :name
      property :tag
    end
  end

  let(:sample_record) { Object.new }

  it "instantiates a search" do
    expect(SampleIndex.new(sample_record)).to be_a(described_class)
  end
end
