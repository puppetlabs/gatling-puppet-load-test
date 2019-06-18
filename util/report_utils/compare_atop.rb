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

# TODO: refactor
comparison_path = ARGV[2] || "./#{result_a_name}_vs_#{result_b_name}.csv"

# def compare_atop(csv_path_a, csv_path_b, comparison_path)
#   split_atop_csv(csv_path_a)
#   split_atop_csv(csv_path_b)
#
#   summary_path_a = csv_path_a.gsub(".csv", ".#{SUMMARY_NAME}.csv")
#   summary_path_b = csv_path_b.gsub(".csv", ".#{SUMMARY_NAME}.csv")
#   summary_comparison_path = comparison_path.gsub(".csv", ".#{SUMMARY_NAME}.csv")
#
#   detail_path_a = csv_path_a.gsub(".csv", ".#{DETAIL_NAME}.csv")
#   detail_path_b = csv_path_b.gsub(".csv", ".#{DETAIL_NAME}.csv")
#   detail_comparison_path = comparison_path.gsub(".csv", ".#{DETAIL_NAME}.csv")
#
#   compare_atop_summary(summary_path_a, summary_path_b, summary_comparison_path)
#   compare_atop_detail(detail_path_a, detail_path_b, detail_comparison_path)
# end
#
# def compare_atop_summary(csv_path_a, csv_path_b, comparison_path)
#   puts "Comparing #{csv_path_a} and #{csv_path_b}"
#   puts "Creating #{comparison_path}"
#
#   result_a = CSV.read(csv_path_a)
#   result_b = CSV.read(csv_path_b)
#
#   CSV.open(comparison_path.to_s, "wb") do |csv|
#     csv << ["", "$RESULT_A", "$RESULT_B", "% diff"]
#
#     action_a = result_a[1][0]
#     duration_a = result_a[1][1]
#     cpu_a = result_a[1][2]
#     mem_a = result_a[1][3]
#     dr_a = result_a[1][4]
#     dw_a = result_a[1][5]
#
#     action_b = result_b[1][0]
#     duration_b = result_b[1][1]
#     cpu_b = result_b[1][2]
#     mem_b = result_b[1][3]
#     dr_b = result_b[1][4]
#     dw_b = result_b[1][5]
#
#     csv << ["Action", action_a, action_b, "N/A"]
#     csv << ["Duration", duration_a, duration_b, diff_perf_results(duration_a, duration_b)]
#     csv << ["Avg CPU", cpu_a, cpu_b, diff_perf_results(cpu_a, cpu_b)]
#     csv << ["Avg MEM", mem_a, mem_b, diff_perf_results(mem_a, mem_b)]
#     csv << ["Avg DSK read", dr_a, dr_b, diff_perf_results(dr_a, dr_b)]
#     csv << ["Avg DSK Write", dw_a, dw_b, diff_perf_results(dw_a, dw_b)]
#   end
#
#   csv2html(comparison_path)
# end
#
# # TODO: get this working
# def compare_atop_detail(csv_path_a, csv_path_b, comparison_path)
#   # puts "Comparing #{csv_path_a} and #{csv_path_b}"
#   # puts "Creating #{comparison_path}"
#
#   # result_a = CSV.read(csv_path_a)
#   # result_b = CSV.read(csv_path_b)
# end

compare_atop_csv_results(result_a_path, result_b_path, comparison_path)
