# frozen_string_literal: true

module Caoutsearch
  module Search
    module QueryBuilder
      module Aggregations
        private

        def build_aggregations
          call_aggregations(*current_aggregations) if current_aggregations
        end

        def call_aggregations(*args)
          args.each do |arg|
            if arg.is_a?(Hash)
              arg.each do |key, value|
                call_aggregation(key, value)
              end
            else
              call_aggregation(arg)
            end
          end
        end

        def call_aggregation(name, *args)
          name = name.to_s

          if self.class.aggregations.include?(name)
            item = self.class.aggregations[name]
            call_aggregation_item(item, *args)
          elsif self.class.aggregations.include?(:__default__)
            block = self.class.aggregations[:__default__]
            instance_exec(name, *args, &block)
          else
            raise "unexpected aggregation: #{name}"
          end
        end

        def call_aggregation_item(item, *args)
          if item.has_block?
            instance_exec(*args, &item.block)
          else
            query.aggregations[item.name] = item.options
          end
        end
      end
    end
  end
end
