# frozen_string_literal: true

module Caoutsearch
  class Mappings
    attr_reader :index_name

    # Build an index mapping
    #
    #   Caoutsearch::Mapping.new({ properties: [...], )
    #
    def initialize(mappings)
      @mappings = mappings.deep_symbolize_keys
    end

    def to_hash
      @mappings
    end
    alias_method :as_json, :to_hash

    def to_json(*)
      MultiJson.dump(as_json)
    end

    def include?(*args)
      find(*args).present?
    end

    def find(*args)
      each_path(*args).map { |hash, _| hash }.last
    end

    def find_type(*args)
      definition = find(*args)
      definition[:type]&.to_s if definition.present?
    end

    def nested?(*args)
      nested_path(*args).present?
    end

    def include_in_parent?(*args)
      path = nested_path(*args)
      return nil unless path

      !!find(path)[:include_in_parent]
    end

    def nested_path(*args)
      return nil unless include?(*args)

      each_path(*args) do |hash, current_path|
        break nil unless hash
        return current_path if hash[:type] == "nested"
      end

      nil
    end

    private

    def key_path(*args)
      args.flat_map { |path| path.to_s.split(".").map(&:to_sym) }
    end

    def each_path(*args)
      return to_enum(:each_path, *args) unless block_given?

      hash = to_hash
      path = []

      key_path(*args).each do |key|
        path << key
        hash = hash.dig(:properties, key) || hash.dig(:fields, key) if hash

        yield hash, path.join(".")
      end
    end
  end
end
