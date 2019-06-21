# frozen_string_literal: true

# TODO: move to perf_results_helper.rb
# TODO: accept release names as optional arguments for A / B

require "csv"
require "../../tests/helpers/perf_results_helper.rb"
include PerfResultsHelper # rubocop:disable Style/MixinUsage

SUMMARY_NAME = "summary"
DETAIL_NAME = "detail"

raise Exception, "you must provide two csv files to compare" unless ARGV[1]

result_a_path = ARGV[0]
result_a_name = File.basename(result_a_path, ".*")

result_b_path = ARGV[1]
result_b_name = File.basename(result_b_path, ".*")

comparison_path = ARGV[2] || "./#{result_a_name}_vs_#{result_b_name}.csv"

compare_atop_csv_results(result_a_path, result_b_path, comparison_path)
