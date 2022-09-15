# frozen_string_literal: true

module Caoutsearch
  module Index
    module Serialization
      extend ActiveSupport::Concern

      included do
        delegate :to_json, to: :as_json
      end

      class_methods do
        # Transform record or array of records to JSON:
        #
        #    transform(nil)               => nil
        #    transform(record.first)      => { ... }
        #    transform(record.limit(100)) => [{ ... }, { ... }, ...]
        #
        def transform(input, *keys)
          if input.nil?
            nil
          elsif input.respond_to?(:map)
            input.map { |record| transform(record, *keys) }
          else
            new(input).as_json(*keys)
          end
        end

        # Convert an array of records to an Elasticsearch bulk payload
        #
        def bulkify(input, method, keys)
          raise ArgumentError, "unknown method #{method}" unless %i[index update delete].include?(method)

          input.reduce([]) do |payload, record|
            payload + new(record).bulkify(method, keys)
          end
        end
      end

      # Serialize the object payload
      #
      def as_json(*keys)
        keys = keys.map(&:to_s)
        _, partial_keys = analyze_keys(keys)

        raise SerializationError, format_keys("cannot serializer the following keys together: %{keys}", partial_keys) if keys.size > 1 && partial_keys.any?

        json = {}
        keys = properties if keys.empty?
        keys.each do |key|
          result = send(key)

          if partial_reindexations.include?(key)
            json = json.merge(result)
          else
            json[key.to_sym] = result
          end
        end

        simplify(json)
      end

      # Recursive objects simplication:
      #
      #   [nil, 'A', 'A', 'B']          => ['A', 'B']
      #   [nil, 'A', 'A']               => 'A'
      #   [nil, nil]                    => nil
      #   []                            => nil
      #
      #   { key: [nil, 'A', 'A', 'B'] } => { key: ['A', 'B'] }
      #   { key: [nil, 'A', 'A'] }      => { key: 'A' }
      #   { key: [nil, nil] }           => { key: nil }
      #   { key: [] }                   => { key: nil }
      #   { }                           => { }
      #
      def simplify(object)
        case object
        when Array
          object = object.filter_map { |array_item| simplify(array_item) }.uniq
          object = object[0] if object.size <= 1
        when Hash
          object.each { |key, value| object[key] = simplify(value) }
        end

        object
      end

      # Convert the object Elasticsearch `header\ndata` payload format
      #
      def bulkify(method, keys)
        raise ArgumentError, "unknown method #{method}" unless %i[index update delete].include?(method)

        keys                        = keys.map(&:to_s)
        payload                     = []
        property_keys, partial_keys = analyze_keys(keys)

        case method
        when :index
          raise SerializationError, format("cannot serialize the following keys: %{keys}", keys: partial_keys.to_sentence) if partial_keys.any?

          payload << { index: { _id: record.id } }
          payload << as_json(*keys)

        when :update
          if property_keys.any?
            payload << { update: { _id: record.id } }
            payload << { doc: as_json(*property_keys) }
          end

          partial_keys.each do |key|
            payload << { update: { _id: record.id } }
            payload << as_json(*key)
          end

        when :delete
          payload << { update: { _id: record.id } }
        end

        payload
      end

      private

      def analyze_keys(keys)
        partial_keys  = partial_reindexations.keys & keys
        property_keys = properties & keys
        unknown_keys  = keys - property_keys - partial_keys

        raise ArgumentError, format("unknown keys: %{keys}", keys: unknown_keys.to_sentence) if unknown_keys.any?

        property_keys = properties & keys
        [property_keys, partial_keys]
      end
    end
  end
end
