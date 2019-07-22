# frozen_string_literal: true

require "simplecov"
require "rspec"

SimpleCov.start do
  add_filter "/spec/"
  add_group "Setup helpers", "setup/helpers"
  add_group "Test helpers", "tests/helpers"
end

# setup helpers
Dir["./setup/helpers/*.rb"].each { |file| require file }

# test helpers
Dir["./tests/helpers/*.rb"].each { |file| require file }

RSpec.configure do |c|
end

RSpec.shared_context "case_info_lets" do
  let(:something) { "some value" }
end

def do_something_helpful(value)
  puts "Do something with #{value}"
end

SimpleCov.at_exit do
  SimpleCov.result.format!
  SimpleCov.minimum_coverage 40
end
