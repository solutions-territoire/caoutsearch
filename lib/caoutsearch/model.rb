# frozen_string_literal: true

module Caoutsearch
  module Model
    extend ActiveSupport::Concern

    included do
      include Indexable
      include Searchable
    end
  end
end
