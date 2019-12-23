# frozen_string_literal: true

require "simplecov"
require "rspec"

SimpleCov.start do
  add_filter "/spec/"
  add_group "Setup helpers", "setup/helpers"
  add_group "Test helpers", "tests/helpers"
  add_group "metrics", "util/metrics"
end

# setup helpers
Dir["./setup/helpers/*.rb"].sort.each { |file| require file }

# test helpers
Dir["./tests/helpers/*.rb"].sort.each { |file| require file }

# metrics scripts
Dir["./util/metrics/*.rb"].sort.each { |file| require file }

SimpleCov.at_exit do
  SimpleCov.result.format!
  SimpleCov.minimum_coverage 40
end
