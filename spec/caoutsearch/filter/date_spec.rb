# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Filter::Date do
  let(:first_date) { Date.new(2022, 10, 1) }
  let(:last_date) { Date.new(2022, 10, 30) }
  let(:first_time) { Time.new(2022, 10, 1, 8, 0, 0, "UTC") }
  let(:last_time) { Time.new(2022, 10, 1, 12, 0, 0, "UTC") }

  def expect_value(input_value)
    expect(described_class.call(:created_at, input_value, :date))
  end

  def generate_terms(*expected_terms)
    eq(expected_terms)
  end

  def generate_range(expected_range)
    eq([{range: {created_at: expected_range}}])
  end

  it { expect_value(true).to generate_terms({exists: {field: :created_at}}) }
  it { expect_value(false).to generate_terms({bool: {must_not: {exists: {field: :created_at}}}}) }

  it { expect_value("2022-10-01").to generate_range({gte: "2022-10-01", lte: "2022-10-01"}) }
  it { expect_value("now-1w/d").to generate_range({gte: "now-1w/d", lte: "now-1w/d"}) }
  it { expect_value(first_date).to generate_range({gte: "2022-10-01", lte: "2022-10-01"}) }

  it { expect_value({lt: "2022-11-21"}).to generate_range({lt: "2022-11-21"}) }
  it { expect_value({gt: "2022-11-21"}).to generate_range({gt: "2022-11-21"}) }
  it { expect_value({lte: "2022-11-21"}).to generate_range({lte: "2022-11-21"}) }
  it { expect_value({gte: "2022-11-21"}).to generate_range({gte: "2022-11-21"}) }

  it { expect_value({less_than: "2022-11-21"}).to generate_range({lt: "2022-11-21"}) }
  it { expect_value({greater_than: "2022-11-21"}).to generate_range({gt: "2022-11-21"}) }
  it { expect_value({less_than_or_equal: "2022-11-21"}).to generate_range({lte: "2022-11-21"}) }
  it { expect_value({greater_than_or_equal: "2022-11-21"}).to generate_range({gte: "2022-11-21"}) }

  it { expect_value({"less_than" => "2022-11-21"}).to generate_range({"lt" => "2022-11-21"}) }
  it { expect_value({"greater_than" => "2022-11-21"}).to generate_range({"gt" => "2022-11-21"}) }
  it { expect_value({"less_than_or_equal" => "2022-11-21"}).to generate_range({"lte" => "2022-11-21"}) }
  it { expect_value({"greater_than_or_equal" => "2022-11-21"}).to generate_range({"gte" => "2022-11-21"}) }

  it do
    expect_value(
      {less_than_or_equal: "2022-10-30", greater_than: "2022-10-15"}
    ).to generate_range(
      {lte: "2022-10-30", gt: "2022-10-15"}
    )
  end

  it do
    expect_value(
      {less_than_or_equal: first_date, greater_than: last_date}
    ).to generate_range(
      {lte: "2022-10-01", gt: "2022-10-30"}
    )
  end

  it "raises an error with an unexpected operator" do
    expect {
      described_class.call(:created_at, {less: "2022-11-21"}, :date)
    }.to raise_error(ArgumentError)
  end

  it { expect_value({between: ["2022-10-01", "2022-10-30"]}).to generate_range({gte: "2022-10-01", lte: "2022-10-30"}) }
  it { expect_value({between: ["now", "now+1w/d"]}).to generate_range({gte: "now", lte: "now+1w/d"}) }
  it { expect_value({between: [first_date, last_date]}).to generate_range({gte: "2022-10-01", lte: "2022-10-30"}) }
  it { expect_value({between: [first_time, last_time]}).to generate_range({gte: "2022-10-01T08:00:00.000Z", lte: "2022-10-01T12:00:00.000Z"}) }

  it { expect_value("2022-10-01".."2022-10-30").to generate_range({gte: "2022-10-01", lte: "2022-10-30"}) }
  it { expect_value("2022-10-01"..."2022-10-30").to generate_range({gte: "2022-10-01", lt: "2022-10-30"}) }
  it { expect_value("2022-10-01"..).to generate_range({gte: "2022-10-01"}) }
  it { expect_value(.."2022-10-01").to generate_range({lte: "2022-10-01"}) }

  it { expect_value("now".."now+1w/d").to generate_range({gte: "now", lte: "now+1w/d"}) }
  it { expect_value(.."now+1w/d").to generate_range({lte: "now+1w/d"}) }
  it { expect_value("now+1w/d"..).to generate_range({gte: "now+1w/d"}) }

  it { expect_value("2022-10-01..2022-10-30").to generate_range({gte: "2022-10-01", lte: "2022-10-30"}) }
  it { expect_value("2022-10-01..").to generate_range({gte: "2022-10-01"}) }
  it { expect_value("..2022-10-01").to generate_range({lte: "2022-10-01"}) }

  it { expect_value("now..now+1w/d").to generate_range({gte: "now", lte: "now+1w/d"}) }
  it { expect_value("..now+1w/d").to generate_range({lte: "now+1w/d"}) }
  it { expect_value("now+1w/d..").to generate_range({gte: "now+1w/d"}) }

  it { expect_value(first_time..last_time).to generate_range({gte: "2022-10-01T08:00:00.000Z", lte: "2022-10-01T12:00:00.000Z"}) }
  it { expect_value(first_date..last_date).to generate_range({gte: "2022-10-01", lte: "2022-10-30"}) }
  it { expect_value(first_date...last_date).to generate_range({gte: "2022-10-01", lt: "2022-10-30"}) }
  it { expect_value(first_date..).to generate_range({gte: "2022-10-01"}) }
  it { expect_value(..last_date).to generate_range({lte: "2022-10-30"}) }

  it { expect_value([["2022-10-01", "2022-10-30"]]).to generate_range({gte: "2022-10-01", lte: "2022-10-30"}) }
  it { expect_value([["2022-10-01", nil]]).to generate_range({gte: "2022-10-01"}) }
  it { expect_value([[nil, "2022-10-01"]]).to generate_range({lte: "2022-10-01"}) }

  it { expect_value([["now", "now+1w/d"]]).to generate_range({gte: "now", lte: "now+1w/d"}) }

  it { expect_value([[first_time, last_time]]).to generate_range({gte: "2022-10-01T08:00:00.000Z", lte: "2022-10-01T12:00:00.000Z"}) }
  it { expect_value([[first_date, last_date]]).to generate_range({gte: "2022-10-01", lte: "2022-10-30"}) }
  it { expect_value([[first_date, nil]]).to generate_range({gte: "2022-10-01"}) }
  it { expect_value([[nil, last_date]]).to generate_range({lte: "2022-10-30"}) }

  it do
    expect_value(
      [true, ..Date.new(2022, 10, 1)]
    ).to generate_terms(
      {exists: {field: :created_at}},
      {range: {created_at: {lte: "2022-10-01"}}}
    )
  end
end
