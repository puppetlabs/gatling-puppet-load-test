# frozen_string_literal: true

require "../../tests/helpers/perf_results_helper.rb"
include PerfResultsHelper # rubocop:disable Style/MixinUsage

# TODO: move to perf_results_helper
# TODO: include this functionality in every performance run
# TODO: extract result names from path

TEMPLATE_PATH = "templates/perf_results_template.html"

RESULT_PATH = "examples/perf_template_defaults/PerfTestLarge-A.csv.html"
RESULT_NAME = "PerfTestLarge-12345678"

OUTPUT_PATH = "examples/example_perf_report.html"

RELEASE_NUMBER = "1.2.3"
RESULT_IMAGE = "perf_template_defaults/release_a.png"

ATOP_SUMMARY_PATH = "examples/perf_template_defaults/atop_log_applestoapples_json.summary.csv.html"
ATOP_DETAIL_PATH = "examples/perf_template_defaults/atop_log_applestoapples_json.detail.csv.html"

def init
  @template_path = ENV["TEMPLATE_PATH"] || TEMPLATE_PATH

  @result_path = ENV["RESULT_PATH"] || RESULT_PATH
  @result_name = ENV["RESULT_NAME"] || RESULT_NAME

  @output_path = ENV["OUTPUT_PATH"] || OUTPUT_PATH

  @release_number = ENV["RELEASE_NUMBER"] || RELEASE_NUMBER
  @result_image = ENV["RESULT_IMAGE"] || RESULT_IMAGE

  @atop_summary_path = ENV["ATOP_SUMMARY_PATH"] || ATOP_SUMMARY_PATH
  @atop_detail_path = ENV["ATOP_TABLE_DETAIL"] || ATOP_DETAIL_PATH
end

# TODO: iterate a hash of param, replacement
def replace_parameters(report)
  puts "replacing parameters..."
  puts

  report = report.gsub("$RELEASE_NUMBER", @release_number)
  report = report.gsub("$RESULT_IMAGE", @result_image)
  report = report.gsub("$RESULT_NAME", @result_name)

  report
end

# TODO: move to perf_results_helper.rb as build_perf_report
def build_report
  puts "building report..."
  puts

  # load template
  report = File.read(@template_path)

  # metrics result
  result_table = extract_table_from_csv2html_output(@result_path)

  # atop summary
  atop_summary_table = extract_table_from_csv2html_output(@atop_summary_path)

  # atop detail
  atop_detail_table = extract_table_from_csv2html_output(@atop_detail_path)

  # replace tables (do this first since table data may include parameters)
  report = report.gsub("$RESULT_TABLE", result_table)
  report = report.gsub("$ATOP_SUMMARY_TABLE", atop_summary_table)
  report = report.gsub("$ATOP_DETAIL_TABLE", atop_detail_table)

  # replace parameters
  report = replace_parameters(report)

  # write report
  puts "writing report to #{@output_path}"

  File.write(@output_path, report)
end

init
build_report
