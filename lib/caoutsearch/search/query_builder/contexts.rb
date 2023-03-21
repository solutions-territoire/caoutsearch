# frozen_string_literal: true

module Caoutsearch
  module Search
    module QueryBuilder
      module Contexts
        private

        def build_contexts
          call_contexts(*current_contexts) if current_contexts
        end

        def call_contexts(*args)
          args.each do |arg|
            call_context(arg)
          end
        end

        def call_context(name)
          name = name.to_s

          if self.class.contexts.include?(name)
            item = self.class.contexts[name]
            call_context_item(item)
          end
        end

        def call_context_item(item)
          instance_exec(&item.block)
        end
      end
    end
  end
end
