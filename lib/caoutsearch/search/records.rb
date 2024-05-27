# frozen_string_literal: true

module Caoutsearch
  module Search
    module Records
      def records(use: nil, skip_query_cache: false)
        if use
          load_records(hits, use: use, skip_query_cache: skip_query_cache)
        else
          @records ||= load_records(hits)
        end
      end

      def load_records(hits, use: nil, **options)
        records_adapter.call(use || model, hits, **options)
      end

      def records_adapter
        if defined?(ActiveRecord::Base)
          Adapter::ActiveRecord
        else
          raise NotImplementedError
        end
      end
    end
  end
end
