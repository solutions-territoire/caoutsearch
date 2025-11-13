# frozen_string_literal: true

module Caoutsearch
  module Concerns
    module Settings
      extend ActiveSupport::Concern

      included do
        delegate :settings, to: :class
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
          Caoutsearch.config.settings.to_hash.dup
        end
      end
    end
  end
end
