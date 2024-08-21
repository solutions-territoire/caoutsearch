# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Instrumentation::Index do
  before do
    Caoutsearch.instrument!(index: true)

    stub_index_class("SampleIndex")
    stub_record_class("Sample")
  end

  pending "TODO"
end
