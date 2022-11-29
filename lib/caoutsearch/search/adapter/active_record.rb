# frozen_string_literal: true

module Caoutsearch
  module Search
    module Adapter
      module ActiveRecord
        def self.call(model, hits, skip_query_cache: false)
          ids = hits.map { |hit| hit["_id"] }

          relation = model.where(model.primary_key => ids).extending(Relation)
          relation.skip_query_cache! if skip_query_cache
          relation.hits = hits
          relation
        end

        module Relation
          attr_reader :hits

          def hits=(values)
            @hits = values
          end

          # Re-order records based on hits order
          #
          def records
            return super if order_values.present? || @_reordered_records

            load
            indexes = @hits.each_with_index.to_h { |hit, index| [hit["_id"].to_s, index] }
            @records = @records.sort_by { |record| indexes[record.id.to_s] }.freeze
            @_reordered_records = true

            @records
          end
        end
      end
    end
  end
end
