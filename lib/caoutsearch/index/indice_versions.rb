# frozen_string_literal: true

module Caoutsearch
  module Index
    module IndiceVersions
      extend ActiveSupport::Concern

      class_methods do
        # List versions
        #
        #   ArticleIndex.indice_versions
        #   => ["articles_v0", "articles_v1"]
        #
        def indice_versions
          client.cat
            .indices(h: ["index"], format: :json)
            .filter_map { |h| h["index"] }
            .grep(indice_version_regexp)
        end

        # List aliased versions
        #
        #   ArticleIndex.aliased_indice_versions
        #   => ["articles_v1"]
        #
        def aliased_indice_versions
          client.indices
            .get_alias(name: index_name)
            .keys
            .grep(indice_version_regexp)
        rescue Elastic::Transport::Transport::Errors::NotFound
          []
        end

        # List last version available (aliased or not)
        #
        #   ArticleIndex.last_indice_version
        #   => "articles_v1"
        #
        def last_indice_version
          indice_versions.max
        end

        # Next version to create
        #
        #   ArticleIndex.next_indice_version
        #   => "articles_v2"
        #
        def next_indice_version
          current_version = last_indice_version

          if current_version
            number = current_version[/_v(\d+)$/, 1].to_i
            "#{index_name}_v#{number + 1}"
          else
            "#{index_name}_v0"
          end
        end

        # Create new version of the index
        #
        #   ArticleIndex.create_indice_version
        #   => "articles_v2"
        #
        def create_indice_version(version_name = next_indice_version)
          client.indices.create(
            index: version_name,
            body: {
              settings: settings.as_json,
              mappings: mappings.as_json
            }
          )

          version_name
        end

        # Switch the index to a new version
        #
        #   ArticleIndex.switch_indice_version("articles_v2")
        #   => true
        #
        def switch_indice_version(version_name = :__last__)
          version_name = last_indice_version if version_name == :__last__

          actions = []
          actions << { add: { index: version_name, alias: index_name } }

          aliased_indice_versions.each do |alias_name|
            return false if alias_name == version_name
            actions << { remove: { index: alias_name, alias: index_name } }
          end

          client.indices.update_aliases(body: { actions: actions })
          refresh_indice
          version_name
        end

        # Prune not-aliased versions
        #
        def prune_indice_versions
          old_versions = indice_versions - aliased_indice_versions
          old_versions.each do |version_name|
            client.indices.delete(index: version_name)
          end
        end

        # Delete all versions, alias or not
        #
        def delete_all_indice_versions
          indice_versions.each do |version_name|
            client.indices.delete(index: version_name)
          end
        end

        private

        def indice_version_regexp
          @version_regexp ||= /^#{index_name}_(v\d+)$/
        end
      end
    end
  end
end
