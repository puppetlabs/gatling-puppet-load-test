# frozen_string_literal: true

require "../../tests/helpers/perf_results_helper.rb"
include PerfResultsHelper # rubocop:disable Style/MixinUsage

TEMPLATE_PATH = "templates/perf_comparison_template.html"

RESULT_COMPARISON_PATH = %w[
  examples
  perf_comparison_template_defaults
  perf_comparison_a_vs_b.csv.html
].join("/")

ATOP_SUMMARY_COMPARISON_PATH = %w[
  examples
  perf_comparison_template_defaults
  atop_comparison_a_vs_b.summary.csv.html
].join("/")

RESULT_A = "PerfTestLarge-12345678"
RELEASE_A_NAME = "Release A"
RELEASE_A_NUMBER = "1.2.3"

RESULT_B = "PerfTestLarge-23456789"
RELEASE_B_NAME = "Release B"
RELEASE_B_NUMBER = "2.3.4"

OUTPUT_PATH = "examples/example_perf_comparison_report.html"

def init
  @template_path = ENV["TEMPLATE_PATH"] || TEMPLATE_PATH

  @result_comparison_path = ENV["RESULT_COMPARISON_PATH"] || RESULT_COMPARISON_PATH
  @atop_summary_comparison_path = ENV["ATOP_SUMMARY_COMPARISON_PATH"] || ATOP_SUMMARY_COMPARISON_PATH

  @result_a = ENV["RESULT_A"] || RESULT_A
  @release_a_name = ENV["RELEASE_A_NAME"] || RELEASE_A_NAME
  @release_a_number = ENV["RELEASE_A_NUMBER"] || RELEASE_A_NUMBER

  @result_b = ENV["RESULT_B"] || RESULT_B
  @release_b_name = ENV["RELEASE_B_NAME"] || RELEASE_B_NAME
  @release_b_number = ENV["RELEASE_B_NUMBER"] || RELEASE_B_NUMBER

  @output_path = ENV["OUTPUT_PATH"] || OUTPUT_PATH
end

# TODO: iterate a hash of param, replacement
def replace_parameters(report)
  puts "replacing parameters..."
  puts

  report = report.gsub("$RESULT_A", @result_a)
  report = report.gsub("$RELEASE_A_NAME", @release_a_name)
  report = report.gsub("$RELEASE_A_NUMBER", @release_a_number)

  report = report.gsub("$RESULT_B", @result_b)
  report = report.gsub("$RELEASE_B_NAME", @release_b_name)
  report = report.gsub("$RELEASE_B_NUMBER", @release_b_number)

  report
end

# TODO: move to perf_results_helper.rb as build_perf_comparison_report
def build_report
  puts "building report..."
  puts

  # load template
  report = File.read(@template_path)

  # metrics result
  result_comparison_table = extract_table_from_csv2html_output(@result_comparison_path)

  # atop summary
  atop_summary_comparison_table = extract_table_from_csv2html_output(@atop_summary_comparison_path)

  # atop detail
  # TODO: enable
  # atop_detail_comparison_table = extract_table(@atop_detail_comparison_path)

  # replace tables (do this first since table data may include parameters)
  report = report.gsub("$RESULT_COMPARISON_TABLE", result_comparison_table)
  report = report.gsub("$ATOP_SUMMARY_COMPARISON_TABLE", atop_summary_comparison_table)

  # TODO: enable
  # report = report.gsub("$ATOP_DETAIL_TABLE", atop_detail_table)

  # replace parameters
  report = replace_parameters(report)

  # write report
  puts "writing report to #{@output_path}"

  File.write(@output_path, report)
end

init
build_report
