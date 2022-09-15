# frozen_string_literal: true

require "zeitwerk"
Zeitwerk::Loader.for_gem.setup

module Caoutsearch
  class << self
    attr_writer :client

    def client
      @client ||= Elasticsearch::Client.new
    end

    def settings
      @settings ||= Caoutsearch::Settings.new({})
    end

    def settings=(settings)
      @settings = Caoutsearch::Settings.new(settings)
    end
  end
end
