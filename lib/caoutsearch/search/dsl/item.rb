# frozen_string_literal: true

module Caoutsearch
  module Search
    module DSL
      class Item
        attr_reader :name, :options, :block

        PROPERTIES_TO_INSPECT = %i[name options block].freeze

        def initialize(name, options = {}, &block)
          @name    = name
          @options = options
          @block   = block if block
        end

        def has_block?
          block.present?
        end

        def indexes
          @indexes ||= Array.wrap(options[:indexes].presence || name)
        end

        def inspect
          properties = properties_to_inspect.map { |k, v| " #{k}: #{v}" }

          "#<#{self.class}#{properties.join(",")}>"
        end

        private

        def properties_to_inspect
          PROPERTIES_TO_INSPECT.each_with_object({}) do |name, properties|
            value = instance_variable_get("@#{name}")
            properties[name] = value.inspect if value.present?
          end
        end
      end
    end
  end
end
