# frozen_string_literal: true

module Caoutsearch
  module Index
    module Reindex
      extend ActiveSupport::Concern

      class_methods do
        # Reindex multiple records with bulk API
        #
        # Examples:
        #     ArticleIndex.reindex(Article.all)
        #     ArticleIndex.reindex(Article.modified_since(2.days), :title, :content)
        #
        # Examples with options:
        #
        #     articles = Article.modified_since(2.days)
        #
        #     ArticleIndex.reindex(articles, index: "article_v3")
        #     ArticleIndex.reindex(articles, batch_size: 10)
        #     ArticleIndex.reindex(articles, method: :update)
        #     ArticleIndex.reindex(articles, method: :update)
        #
        # When passing a limited set of records (< 100), you can pass a `limited_set` option to avoid
        # extra queries
        #     ArticleIndex.reindex(Article.limit(100), limited_set: true)
        #
        def reindex(records, *keys, **options)
          options.assert_valid_keys(:index, :refresh, :batch_size, :method, :total, :progress)
          keys.flatten!

          records = apply_scopes(records, keys)
          records = records.strict_loading

          index            = options.fetch(:index, index_name)
          refresh          = options.fetch(:refresh, false)
          batch_size       = options.fetch(:batch_size, 100)
          method           = options.fetch(:method) { keys.present? ? :update : :index }
          total            = options.fetch(:total)  { records.count(:all) }
          progress         = options[:progress]
          current_progress = 0

          return if total.zero?

          progress&.total    = total
          progress&.progress = current_progress

          if total <= batch_size
            finder = records.to_a.each_slice(total)
          else
            finder = records.find_in_batches(batch_size: batch_size)
          end

          finder.each do |batch|
            current_progress += batch.size
            request_payload   = {
              index:  index,
              body:   bulkify(batch, method, keys)
            }

            instrument(:reindex, total: total, progress: current_progress) do |event_payload|
              event_payload[:request]  = request_payload
              event_payload[:response] = client.bulk(request_payload)
            end

            progress&.increment(batch.size)
            records.connection.clear_query_cache
          end

          refresh_indice(index: index) if refresh
        end

        alias_method :update_documents, :reindex
      end
    end
  end
end
