# frozen_string_literal: true

module Caoutsearch
  module Config
    module Settings
      extend ActiveSupport::Concern

      included do
        delegate :mappings, to: :class
      end

      class_methods do
        def settings
          @settings ||= Caoutsearch::Settings.new(default_settings)
        end

        def settings=(settings)
          @settings = Caoutsearch::Settings.new(settings)
        end

        protected

        def default_settings
          Caoutsearch.settings.to_hash.dup
        end
      end
    end
  end
end
