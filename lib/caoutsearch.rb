# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "elasticsearch"
require "hashie"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/caoutsearch/testing.rb")
loader.ignore("#{__dir__}/caoutsearch/testing")
loader.inflector.inflect("dsl" => "DSL")
loader.inflector.inflect("internal_dsl" => "InternalDSL")
loader.inflector.inflect("none" => "NONE")
loader.setup

module Caoutsearch
  class << self
    def config
      @config ||= Configuration.new
    end
    alias_method :configuration, :config

    def configure
      yield(configuration)
    end

    def reset_config
      @config = Configuration.new
    end
  end
end
