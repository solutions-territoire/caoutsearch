# frozen_string_literal: true

module Caoutsearch
  module Search
    module Sanitizer
      ESCAPED_CHARACTERS        = "\+-&|!(){}[]^~*?:"
      ESCAPED_CHARACTERS_REGEXP = /([+\-&|!(){}\[\]\^~*?:])/.freeze

      class << self
        def sanitize(value, characters = ESCAPED_CHARACTERS)
          case value
          when Array
            value.map { |v| sanitize(v) }
          when Hash
            value.each { |k, v| value[k] = sanitize(v) }
          when String
            regexp   = ESCAPED_CHARACTERS_REGEXP if characters == ESCAPED_CHARACTERS
            regexp ||= Regexp.new("([#{Regexp.escape(characters)}])")

            value.gsub(regexp, '\\\\\1')
          else
            value
          end
        end
      end
    end
  end
end
