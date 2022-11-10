# frozen_string_literal: true

module Caoutsearch
  module Index
    module InternalDSL
      extend ActiveSupport::Concern

      included do
        # Be careful with these class attributes
        # Always use `+=` or `.dup.merge` to assign a new copy
        #
        class_attribute :properties, instance_writer: false, default: []
        class_attribute :partial_reindexations, instance_writer: false, default: {}
      end

      class_methods do
        # Declare a property
        #
        #   class ArticleIndex < Caoutsearch::Index::Base
        #     property :title
        #     property :description
        #     property :tags
        #
        #     def tags
        #       record.tags.map do |tag|
        #         {
        #           label: tag.label,
        #           score: tag.score
        #         }
        #        end
        #     end
        #   end
        #
        def property(key, body = nil)
          raise ArgumentError, "The property body needs to be callable." if body && !body.respond_to?(:call)

          key = key.to_s
          self.properties += [key] unless properties.include?(key)

          define_method(key, &body) if body
        end

        # Declare an alias-property for partial reindexation
        #
        #   class LocalIndex < Caoutsearch::Index::Base
        #     property :invariant
        #     property :geoaddress
        #     property :geoposition
        #
        #     allow_partial_reindex :post_processed_data, properties: %i[geoaddress occupation]
        #   end
        #
        def allow_partial_reindex(name, body = nil, properties: nil, upsert: false)
          raise ArgumentError, "The allow_partial_reindex body needs to be callable." if body && !body.respond_to?(:call)

          name = name.to_s
          self.partial_reindexations = partial_reindexations.dup.merge(name => {properties: properties})

          if body
            define_method(name, &body)
          else
            define_method(name) do
              body = {doc: properties.index_with { |key| send(key) }}
              body[:doc_as_upsert] = true if upsert
              body
            end
          end
        end

        def allow_reindex?(subject)
          subject = subject.to_s
          properties.include?(subject) || partial_reindexations.include?(subject)
        end
      end
    end
  end
end
