# frozen_string_literal: true

module Caoutsearch
  module Config
    module Mappings
      extend ActiveSupport::Concern

      included do
        delegate :mappings, to: :class
      end

      class_methods do
        def mappings
          @mappings ||= Caoutsearch::Mappings.new(default_mappings)
        end

        def mappings=(mappings)
          @mappings = Caoutsearch::Mappings.new(mappings)
        end

        def remote_mappings
          @remote_mappings ||= Caoutsearch::Mappings.new(get_remote_mappings)
        end

        protected

        def default_mappings
          if defined?(Rails)
            path = ::Rails.root.join("config/elasticsearch/#{index_name}.json")
          else
            raise NotImplementedError, "Mappings files cannot be found out of a Rails application"
          end
          raise ArgumentError, "No mappings file found for #{index_name} at #{path}" unless path.exist?

          MultiJson.load(path.read)
        end

        def get_remote_mappings
          client.indices.get_mapping(index: index_name).values[0]["mappings"]
        end
      end
    end
  end
end
