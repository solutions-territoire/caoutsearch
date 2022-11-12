# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "standard/rake"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

# FYI: standard must be called before rubocop
# or it'll report offenses from other plugins waiting in .rubocop_todo.yml
# https://github.com/testdouble/standard/issues/480

task default: %i[spec standard rubocop]
