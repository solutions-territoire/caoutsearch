# frozen_string_literal: true

require "bundler/setup"
Bundler.setup

require "caoutsearch"

RSpec.configure do |config|
  config.order = "random"
  config.expect_with :rspec do |expect|
    expect.syntax = :expect
  end
end
