# frozen_string_literal: true

require_relative "../../tests/helpers/perf_results_helper.rb"
include PerfResultsHelper # rubocop:disable Style/MixinUsage

raise Exception, "you must provide a csv file" unless ARGV[0]

csv_path = ARGV[0]
split_atop_csv_results csv_path
