# frozen_string_literal: true

module Caoutsearch
  module Search
    module BatchMethods
      def find_hits_in_batches(implementation: :search_after, **options)
        return to_enum(:find_hits_in_batches, **options) unless block_given?

        method(implementation).call(**options) do |hits, _progress|
          yield hits
        end
      end

      def find_records_in_batches(**options)
        return to_enum(:find_records_in_batches, **options) unless block_given?

        find_hits_in_batches(**options) do |hits|
          yield records_adapter.call(model, hits, skip_query_cache: true)
        end
      end

      def find_each_record(**options, &block)
        return to_enum(:find_each_record, **options) unless block

        find_records_in_batches(**options) do |relation|
          relation.each(&block)
        end
      end

      def scroll_records_in_batches(**options)
        ActiveSupport::Deprecation.warn("scroll_records_in_batches is deprecated, use find_records_in_batches instead")
        find_records_in_batches(implementation: :scroll, **options)
      end

      def scroll_records(**options)
        ActiveSupport::Deprecation.warn("scroll_records is deprecated, use find_each_record instead")
        find_each_record(implementation: :scroll, **options)
      end
    end
  end
end
