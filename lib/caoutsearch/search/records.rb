# frozen_string_literal: true

module Caoutsearch
  module Search
    module Records
      def records(use: nil, skip_query_cache: false)
        if use
          records_adapter.call(use, hits, skip_query_cache: skip_query_cache)
        else
          @records ||= records_adapter.call(model, hits)
        end
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
