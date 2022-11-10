# frozen_string_literal: true

module Caoutsearch
  module Filter
    class GeoPoint < Base
      def filter
        {geo_distance: {:distance => "1mm", key => value}}
      end
    end
  end
end
