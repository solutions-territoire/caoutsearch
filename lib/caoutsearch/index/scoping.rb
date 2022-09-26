# frozen_string_literal: true

module Caoutsearch
  module Index
    module Scoping
      extend ActiveSupport::Concern

      included do
        class_attribute :scopes,   instance_accessor: false, default: {}
        class_attribute :preloads, instance_accessor: false, default: {}
      end

      class_methods do
        def default_scope(body)
          scope :_default, body
        end

        def scope(name, body)
          raise ArgumentError, "The scope body needs to be callable." unless body.respond_to?(:call)

          name = name.to_s
          self.scopes = scopes.dup.merge(name => body)
        end

        def preload(name, with: nil)
          name = name.to_s
          with = Array.wrap(with || name)

          scope name, ->(records) { records.preload(*with) }
        end

        private

        def apply_scopes(records, names = [])
          names = names.map(&:to_s)
          names = properties if names.empty?
          names += %w[_default] # Use += instead of << to create a copy

          names.each do |name|
            if scopes.include?(name)
              scope   = scopes[name]
              records = scope.call(records)
            elsif partial_reindexations.include?(name)
              properties = partial_reindexations.dig(name, :properties)
              records    = apply_scopes(records, properties) if properties&.any?
            end
          end

          records
        end
      end
    end
  end
end
