# frozen_string_literal: true

module Caoutsearch
  module Search
    module Query
      module Merge
        def merge(other_hash)
          dup.merge!(other_hash)
        end

        def merge!(other_hash)
          merged_hash = to_h.deep_merge(other_hash) do |key, this_val, other_val|
            if this_val.is_a?(Array) && other_val.is_a?(Array)
              (this_val + other_val).uniq
            elsif block_given?
              yield key, this_val, other_val
            else
              other_val
            end
          end

          super(merged_hash)
        end
      end
    end
  end
end
