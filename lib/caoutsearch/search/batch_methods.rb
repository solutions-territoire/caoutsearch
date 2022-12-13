# frozen_string_literal: true

module Caoutsearch
  module Search
    module BatchMethods
      def find_each_hit(**options, &block)
        return to_enum(:find_each_hit, **options) { total_count } unless block

        find_hits_in_batches(**options) do |hits|
          hits.each(&block)
        end
      end

      def find_each_record(**options, &block)
        return to_enum(:find_each_record, **options) { total_count } unless block

        find_records_in_batches(**options) do |relation|
          relation.each(&block)
        end
      end

      def find_records_in_batches(**options)
        unless block_given?
          return to_enum(:find_records_in_batches, **options) do
            find_hits_in_batches(**options).size
          end
        end

        find_hits_in_batches(**options) do |hits|
          yield records_adapter.call(model, hits, skip_query_cache: true)
        end
      end

      def find_hits_in_batches(implementation: :search_after, **options)
        batch_size = options[:batch_size]&.to_i || @current_limit&.to_i || 1000

        unless block_given?
          return to_enum(:find_hits_in_batches, **options) do
            total_count.div(batch_size) + 1
          end
        end

        unless %i[search_after scroll].include?(implementation)
          raise ArgumentError, "unexpected implementation argument: #{implementation.inspect}"
        end

        method(implementation).call(batch_size: batch_size, **options) do |hits|
          yield hits
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
