# frozen_string_literal: true

require "json"
require "csv"
require "../../tests/helpers/perf_results_helper.rb"
include PerfResultsHelper # rubocop:disable Style/MixinUsage

raise Exception, "you must provide a results directory" unless ARGV[0]

results_dir = ARGV[0]
gatling2csv(results_dir)
