# frozen_string_literal: true

module Caoutsearch
  module Filter
    class << self
      def filters
        @filters ||= {}
      end

      def [](key)
        @filters[key.to_s]
      end

      def register(filter_class, as: nil)
        as ||= filter_class.name.demodulize.underscore

        @filters ||= {}
        @filters[as] = filter_class
      end
    end
  end
end

Caoutsearch::Filter.register(Caoutsearch::Filter::Boolean)
Caoutsearch::Filter.register(Caoutsearch::Filter::BoundingBox)
Caoutsearch::Filter.register(Caoutsearch::Filter::Date)
Caoutsearch::Filter.register(Caoutsearch::Filter::Default)
Caoutsearch::Filter.register(Caoutsearch::Filter::GeoPoint)
Caoutsearch::Filter.register(Caoutsearch::Filter::Match)
Caoutsearch::Filter.register(Caoutsearch::Filter::Range)
