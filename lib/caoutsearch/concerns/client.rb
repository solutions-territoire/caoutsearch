# frozen_string_literal: true

module Caoutsearch
  module Concerns
    module Client
      extend ActiveSupport::Concern

      included do
        class_attribute :client, default: Caoutsearch.config.client
      end
    end
  end
end
