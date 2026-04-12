# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Search::TypeCast do
  describe "boolean casting" do
    it { expect(described_class.cast(:boolean, true)).to be(true) }
    it { expect(described_class.cast(:boolean, "1")).to be(true) }
    it { expect(described_class.cast(:boolean, "on")).to be(true) }
    it { expect(described_class.cast(:boolean, "true")).to be(true) }

    it { expect(described_class.cast(:boolean, false)).to be(false) }
    it { expect(described_class.cast(:boolean, "0")).to be(false) }
    it { expect(described_class.cast(:boolean, "off")).to be(false) }
    it { expect(described_class.cast(:boolean, "false")).to be(false) }

    it { expect(described_class.cast(:boolean, [true])).to eq([true]) }
    it { expect(described_class.cast(:boolean, [false])).to eq([false]) }
    it { expect(described_class.cast(:boolean, ["false", "1", "true", ""])).to eq([false, true]) }
  end

  describe "date casting" do
    describe "allows date strings" do
      it { expect(described_class.cast(:date, "2022-10-11")).to eq("2022-10-11") }
      it { expect(described_class.cast(:date, "2022-10-25 11:57:38 +0200")).to eq("2022-10-25 11:57:38 +0200") }
    end

    describe "allows dates and datetimes" do
      it { expect(described_class.cast(:date, Date.new(2022, 10, 11))).to eq("2022-10-11") }
      it { expect(described_class.cast(:date, DateTime.new(2022, 10, 11, 10, 0o5))).to eq("2022-10-11T10:05:00.000+00:00") }
    end

    describe "allows date math" do
      it { expect(described_class.cast(:date, "now")).to eq("now") }
      it { expect(described_class.cast(:date, "now+1y")).to eq("now+1y") }
      it { expect(described_class.cast(:date, "now-1M")).to eq("now-1M") }
      it { expect(described_class.cast(:date, "now-1w/d")).to eq("now-1w/d") }
      it { expect(described_class.cast(:date, "now+1d/d")).to eq("now+1d/d") }
      it { expect(described_class.cast(:date, "now-1h/d")).to eq("now-1h/d") }
      it { expect(described_class.cast(:date, "now-1H/d")).to eq("now-1H/d") }
      it { expect(described_class.cast(:date, "now-1m/d")).to eq("now-1m/d") }
      it { expect(described_class.cast(:date, "now+1s")).to eq("now+1s") }
    end

    describe "raises an error on invalid date" do
      it { expect { described_class.cast(:date, "invalid_string") }.to raise_error(ArgumentError) }
      it { expect { described_class.cast(:date, "now+-1m") }.to raise_error(ArgumentError) }
    end
  end
end
