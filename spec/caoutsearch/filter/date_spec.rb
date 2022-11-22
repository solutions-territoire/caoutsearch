# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Filter::Date do
  context "with boolean input" do
    it "generates a filter on field with data" do
      expect(described_class.new(:created_at, true, :date).as_json).to eq([
        {exists: {field: :created_at}}
      ])
    end

    it "generates on field without data" do
      expect(described_class.new(:created_at, false, :date).as_json).to eq([
        {bool: {must_not: {exists: {field: :created_at}}}}
      ])
    end
  end

  context "with deprecated hash input" do
    it "generates a filter on field where value is less_than" do
      expect(described_class.new(:created_at, {operator: "less_than", value: "2022-11-21"}, :date).as_json).to eq([
        {range: {created_at: {gte: "2022-11-21"}}}
      ])
    end

    it "generates a filter on field where value is greater_than" do
      expect(described_class.new(:created_at, {operator: "greater_than", value: "2022-11-21"}, :date).as_json).to eq([
        {range: {created_at: {lt: "2022-11-21"}}}
      ])
    end

    it "generates a filter on field where value is between" do
      expect(described_class.new(:created_at, {operator: "between", value: ["2022-11-21", "2022-11-24"]}, :date).as_json).to eq([
        {range: {created_at: {gte: "2022-11-21", lt: "2022-11-24"}}}
      ])
    end

    describe "with various date format" do
      before { Timecop.freeze(Time.local(2020, 9, 2, 11, 59, 0)) }

      it "handles dates as strings" do
        expect(described_class.new(:created_at, {operator: "greater_than", value: "2022-11-21"}, :date).as_json).to eq([
          {range: {created_at: {lt: "2022-11-21"}}}
        ])
      end

      it "handles durations" do
        expect(described_class.new(:created_at, {operator: "greater_than", value: 3.weeks}, :date).as_json).to eq([
          {range: {created_at: {lt: "2020-08-12"}}}
        ])
      end

      it "handles days durations in string" do
        expect(described_class.new(:created_at, {operator: "greater_than", value: 3, unit: "day"}, :date).as_json).to eq([
          {range: {created_at: {lt: "2020-08-30"}}}
        ])
      end

      it "handles weeks durations in string" do
        expect(described_class.new(:created_at, {operator: "greater_than", value: 3, unit: "week"}, :date).as_json).to eq([
          {range: {created_at: {lt: "2020-08-12"}}}
        ])
      end

      it "handles months durations in string" do
        expect(described_class.new(:created_at, {operator: "greater_than", value: 3, unit: "month"}, :date).as_json).to eq([
          {range: {created_at: {lt: "2020-06-02"}}}
        ])
      end

      it "handles years durations in string" do
        expect(described_class.new(:created_at, {operator: "greater_than", value: 3, unit: "year"}, :date).as_json).to eq([
          {range: {created_at: {lt: "2017-09-02"}}}
        ])
      end
    end
  end

  context "with hash input" do
    it "generates a filter on field where value is less_than" do
      expect(described_class.new(:created_at, {less_than: "2022-11-21"}, :date).as_json).to eq([
        {range: {created_at: {lt: "2022-11-21"}}}
      ])
    end

    it "generates a filter on field where value is less_than_or_equal" do
      expect(described_class.new(:created_at, {less_than_or_equal: Date.new(2022, 10, 1)}, :date).as_json).to eq([
        {range: {created_at: {lte: "2022-10-01"}}}
      ])
    end

    it "generates a filter on field where value is greater_than" do
      expect(described_class.new(:created_at, {greater_than: "now-1w"}, :date).as_json).to eq([
        {range: {created_at: {gt: "now-1w"}}}
      ])
    end

    it "generates a filter on field where value is between" do
      expect(described_class.new(:created_at, {between: [Date.new(2022, 10, 1), Date.new(2022, 10, 2)]}, :date).as_json).to eq([
        {range: {created_at: {gte: "2022-10-01", lte: "2022-10-02"}}}
      ])
    end

    it "generates a filter on field with more than one operator" do
      expect(described_class.new(:created_at, {less_than_or_equal: Date.new(2022, 10, 1), greater_than: Date.new(2022, 10, 2)}, :date).as_json).to eq([
        {range: {created_at: {lte: "2022-10-01", gt: "2022-10-02"}}}
      ])
    end

    it "raises an error for unknown operator" do
      expect { described_class.new(:created_at, {less: Date.new(2022, 10, 1)}) }
        .to raise_error(ArgumentError)
    end
  end

  context "with range input" do
    it "generates a filter on field where value is between" do
      expect(described_class.new(:created_at, (Date.new(2022, 10, 1)..Date.new(2022, 10, 2)), :date).as_json).to eq([
        {range: {created_at: {gte: "2022-10-01", lte: "2022-10-02"}}}
      ])
    end

    it "generates a filter on field where value is greater than or equal" do
      expect(described_class.new(:created_at, Date.new(2022, 10, 1).., :date).as_json).to eq([
        {range: {created_at: {gte: "2022-10-01"}}}
      ])
    end

    it "generates a filter on field where value is less than or equal" do
      expect(described_class.new(:created_at, ..Date.new(2022, 10, 1), :date).as_json).to eq([
        {range: {created_at: {lte: "2022-10-01"}}}
      ])
    end
  end

  context "with array input" do
    it "generates a filter on field where value is between" do
      expect(described_class.new(:created_at, [[Date.new(2022, 10, 1), Date.new(2022, 10, 2)]], :date).as_json).to eq([
        {range: {created_at: {gte: "2022-10-01", lte: "2022-10-02"}}}
      ])
    end

    it "generates a filter on field where value is greater than or equal" do
      expect(described_class.new(:created_at, [[Date.new(2022, 10, 1), nil]], :date).as_json).to eq([
        {range: {created_at: {gte: "2022-10-01"}}}
      ])
    end

    it "generates a filter on field where value is less than or equal" do
      expect(described_class.new(:created_at, [[nil, Date.new(2022, 10, 1)]], :date).as_json).to eq([
        {range: {created_at: {lte: "2022-10-01"}}}
      ])
    end
  end

  context "with dates" do
    it "generates a filter on field where value is date" do
      expect(described_class.new(:created_at, Date.new(2022, 10, 12), :date).as_json).to eq([
        {range: {created_at: {gte: "2022-10-12", lte: "2022-10-12"}}}
      ])
    end

    it "generates a filter on field where value is date with date math" do
      expect(described_class.new(:created_at, "now-1w/d", :date).as_json).to eq([
        {range: {created_at: {gte: "now-1w/d", lte: "now-1w/d"}}}
      ])
    end
  end

  context "with more than one input" do
    it "mixes inputs" do
      expect(described_class.new(:created_at, [true, ..Date.new(2022, 10, 1)], :date).as_json).to eq([
        {exists: {field: :created_at}},
        {range: {created_at: {lte: "2022-10-01"}}}
      ])
    end
  end
end
