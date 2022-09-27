# frozen_string_literal: true

module Caoutsearch
  module Search
    module Search
      module Response
        delegate :empty?, :size, :slice, :[], :to_a, :to_ary, to: :hits
        delegate_missing_to :each

        def response
          load unless @response
          @response
        end

        def took
          response["took"]
        end

        def timed_out
          response["timed_out"]
        end

        def shards
          response["_shards"]
        end

        def hits
          response.dig("hits", "hits")
        end

        def max_score
          response.dig("hits", "max_score")
        end

        def total
          response.dig("hits", "total")
        end

        def total_count
          if !@track_total_hits && (!loaded? || response.dig("hits", "total", "relation") == "gte")
            @total_count ||= spawn.track_total_hits!(true).source!(false).limit!(0).total_count
          else
            response.dig("hits", "total", "value")
          end
        end

        def total_pages
          (total_count.to_f / current_limit).ceil
        end

        def ids
          hits.pluck("_id")
        end

        def aggregations
          response.dig("aggregations")
        end

        def suggestions
          response.dig("suggest")
        end

        def records
          @records ||= begin
            relation = model.where(model.primary_key => ids).extending do
              attr_reader :hits

              def hits=(values)
                @hits = values
              end

              # Re-order records based on hits order
              #
              def records
                return super if order_values.present? || @_reordered_records

                load
                indexes  = @hits.each_with_index.to_h { |hit, index| [hit["_id"].to_s, index] }
                @records = @records.sort_by { |record| indexes[record.id.to_s] }.freeze
                @_reordered_records = true

                @records
              end
            end

            relation.hits = hits
            relation
          end
        end

        def each(&block)
          return to_enum(:each) { hits.size } unless block

          hits.each(&block)
        end

        def load
          @response = Caoutsearch::Search::Response.new(perform_search_query(build.to_h))
          self
        end

        def loaded?
          !!@response
        end

        def perform_search_query(query)
          request_payload = {
            index:  index_name,
            body:   query
          }

          instrument(:search) do |event_payload|
            event_payload[:request]  = request_payload
            event_payload[:response] = client.search(request_payload)
          end
        end
      end
    end
  end
end
