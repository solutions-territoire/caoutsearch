# frozen_string_literal: true

module Caoutsearch
  module Index
    module Indice
      extend ActiveSupport::Concern

      included do
        delegate :refresh_indice, to: :class
      end

      class_methods do
        # Create index or an alias
        #
        #   ArticleIndex.create_indice
        #
        def create_indice
          client.indices.create(
            index: index_name,
            body: {
              settings: settings.as_json,
              mappings: mappings.as_json
            }
          )
        end

        # Verify index existence
        #
        #   ArticleIndex.indice_exists?
        #   => true
        #
        def indice_exists?
          client.indices.exists?(index: index_name)
        end

        # Verify index existence
        #
        #   ArticleIndex.delete_indice
        #
        def delete_indice
          client.indices.delete(index: index_name)
        end

        # Explicitly refresh one or more index, making all operations performed
        # since the last refresh available for search.
        #
        #   ArticleIndex.refresh_indice
        #
        def refresh_indice
          client.indices.refresh(index: index_name)
        end
      end
    end
  end
end
