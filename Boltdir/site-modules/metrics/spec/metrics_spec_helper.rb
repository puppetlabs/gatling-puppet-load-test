# frozen_string_literal: true

require "simplecov"
require "rspec"

SimpleCov.start do
  add_filter "/spec/"
  add_group "metrics", "files"
end

# files
Dir["./Boltdir/site-modules/metrics/files/*.rb"].each { |file| require file }

SimpleCov.at_exit do
  SimpleCov.result.format!
  SimpleCov.minimum_coverage 40
end
