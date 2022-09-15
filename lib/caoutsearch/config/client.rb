# frozen_string_literal: true

module Caoutsearch
  module Config
    module Client
      extend ActiveSupport::Concern

      included do
        class_attribute :client, default: Caoutsearch.client
      end
    end
  end
end
