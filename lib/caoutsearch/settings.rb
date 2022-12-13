# frozen_string_literal: true

module Caoutsearch
  class Settings
    # Build an index mapping
    #
    #   Caoutsearch::Settings.new(number_of_replicas: 2)
    #
    def initialize(settings = {})
      @settings = settings.deep_symbolize_keys
    end

    def to_hash
      @settings
    end
    alias_method :as_json, :to_hash

    def to_json(*)
      MultiJson.dump(as_json)
    end
  end
end
