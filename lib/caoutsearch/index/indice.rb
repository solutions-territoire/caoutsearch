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

        # Manipulate aliases
        #
        #   ArticleIndex.indice_aliases
        #   => ["articles_v1"]
        #
        #   ArticleIndex.create_indice_alias("articles_v2")
        #   ArticleIndex.update_indice_aliases("articles_v2")
        #
        def indice_aliases
          client.indices.get_alias(name: index_name).keys
        rescue ::Elastic::Transport::Transport::Errors::NotFound
          []
        end

        def create_indice_alias(alias_name)
          client.indices.create(
            index: alias_name,
            body: {
              settings: settings.as_json,
              mappings: mappings.as_json
            }
          )
        end

        def delete_indice_alias(alias_name)

        def update_indice_aliases(alias_names)
          new_alias_names = Array.wrap(alias_names).map(&:to_s)
          old_alias_names = indice_aliases.map(&:to_s) - new_alias_names
          actions         = []

          new_alias_names.each do |alias_name|
            actions << { add: { index: alias_name, alias: index_name } }
          end

          old_alias_names.each do |alias_name|
            actions << { remove: { index: alias_name, alias: index_name } }
          end

          client.indices.update_aliases(body: { actions: actions })
          refresh_indice
        end
      end
    end
  end
end
