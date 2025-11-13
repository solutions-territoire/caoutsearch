# frozen_string_literal: true

require "spec_helper"

RSpec.describe Caoutsearch::Configuration do
  context "with default config" do
    it "sets a default client" do
      expect(Caoutsearch.config.client).to be_a(Elasticsearch::Client)
    end

    it "sets a default client for indexes" do
      expect(Caoutsearch.config.index.client)
        .to be_a(Elasticsearch::Client)
        .and eq(Caoutsearch.config.client)
    end

    it "sets a default client for searches" do
      expect(Caoutsearch.config.search.client)
        .to be_a(Elasticsearch::Client)
        .and eq(Caoutsearch.config.client)
    end

    it "sets default settings", :aggregate_failures do
      expect(Caoutsearch.config.settings).to be_a(Caoutsearch::Settings)
      expect(Caoutsearch.config.settings.to_hash).to eq({})
    end

    it "set indexes instrumentation" do
      expect(Caoutsearch.config.index.instrumentation_format).to be_nil
    end

    it "set searches instrumentation" do
      expect(Caoutsearch.config.search.instrumentation_format).to be_nil
    end
  end

  context "with only one custom configuration" do
    let(:client) { Elasticsearch::Client.new(host: "https://my-elasticsearch-host.example") }

    before do
      Caoutsearch.configure do |config|
        config.client = client
        config.settings = {
          number_of_shards: 5,
          number_of_replicas: 2
        }

        config.instrument
      end
    end

    after do
      Caoutsearch.reset_config
    end

    it "sets the default client" do
      expect(Caoutsearch.config.client).to be(client)
    end

    it "sets the default client for indexes" do
      expect(Caoutsearch.config.index.client).to be(client)
    end

    it "sets the default client for searches" do
      expect(Caoutsearch.config.search.client).to be(client)
    end

    it "sets the default settings", :aggregate_failures do
      expect(Caoutsearch.config.settings).to be_a(Caoutsearch::Settings)
      expect(Caoutsearch.config.settings.to_hash).to eq({
        number_of_shards: 5,
        number_of_replicas: 2
      })
    end

    it "set indexes instrumentation" do
      expect(Caoutsearch.config.index.instrumentation_format).to eq("full")
    end

    it "set searches instrumentation" do
      expect(Caoutsearch.config.search.instrumentation_format).to eq("full")
    end
  end

  context "with a custom index configuration" do
    let(:client) { Elasticsearch::Client.new(host: "https://my-elasticsearch-host.example") }
    let(:another_client) { Elasticsearch::Client.new(host: "https://another-elasticsearch-host.example") }

    before do
      Caoutsearch.configure do |config|
        config.client = client
        config.settings = {
          number_of_shards: 5,
          number_of_replicas: 2
        }

        config.instrument

        config.index do |index|
          index.client = another_client
          index.instrument :truncated
        end
      end
    end

    after do
      Caoutsearch.reset_config
    end

    it "sets the default client" do
      expect(Caoutsearch.config.client).to be(client)
    end

    it "sets another client for indexes" do
      expect(Caoutsearch.config.index.client).to be(another_client)
    end

    it "sets the default client for searches" do
      expect(Caoutsearch.config.search.client).to be(client)
    end

    it "set indexes instrumentation" do
      expect(Caoutsearch.config.index.instrumentation_format).to eq("truncated")
    end

    it "set searches instrumentation" do
      expect(Caoutsearch.config.search.instrumentation_format).to eq("full")
    end
  end

  context "with a custom search configuration" do
    let(:client) { Elasticsearch::Client.new(host: "https://my-elasticsearch-host.example") }
    let(:another_client) { Elasticsearch::Client.new(host: "https://another-elasticsearch-host.example") }

    before do
      Caoutsearch.configure do |config|
        config.client = client
        config.settings = {
          number_of_shards: 5,
          number_of_replicas: 2
        }

        config.instrument

        config.search do |search|
          search.client = another_client
          search.instrument :amazing_print
        end
      end
    end

    after do
      Caoutsearch.reset_config
    end

    it "sets the default client" do
      expect(Caoutsearch.config.client).to be(client)
    end

    it "sets another client for searches" do
      expect(Caoutsearch.config.search.client).to be(another_client)
    end

    it "sets the default client for indexes" do
      expect(Caoutsearch.config.index.client).to be(client)
    end

    it "set indexes instrumentation" do
      expect(Caoutsearch.config.index.instrumentation_format).to eq("full")
    end

    it "set searches instrumentation" do
      expect(Caoutsearch.config.search.instrumentation_format).to eq("amazing_print")
    end
  end
end
