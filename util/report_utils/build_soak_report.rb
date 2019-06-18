# rubocop: disable Style/FrozenStringLiteralComment

require "../../tests/helpers/perf_results_helper.rb"
include PerfResultsHelper # rubocop:disable Style/MixinUsage

# TODO: include this functionality in every performance run
# TODO: extract result names from path

TEMPLATE_PATH = "templates/soak_results_template.html".freeze

RESULT_A_PATH = "examples/soak_template_defaults/PerfTestLarge-A.csv.html".freeze
RESULT_A_NAME = "PerfTestLarge-12345678".freeze

RESULT_B_PATH = "examples/soak_template_defaults/PerfTestLarge-B.csv.html".freeze
RESULT_B_NAME = "PerfTestLarge-23456789".freeze

COMPARISON_PATH = "examples/soak_template_defaults/PerfTestLarge-A_vs_PerfTestLarge-B.csv.html".freeze
OUTPUT_PATH = "examples/example_soak_report.html".freeze

RELEASE_A_NAME = "RELEASE A".freeze
RELEASE_A_NUMBER = "1.2.3".freeze
RELEASE_A_IMAGE = "soak_template_defaults/release_a.png".freeze

RELEASE_B_NAME = "RELEASE B".freeze
RELEASE_B_NUMBER = "2.3.4".freeze
RELEASE_B_IMAGE = "soak_template_defaults/release_b.png".freeze

def init
  @template_path = ENV["TEMPLATE_PATH"] || TEMPLATE_PATH

  @result_a_path = ENV["RESULT_A_PATH"] || RESULT_A_PATH
  @result_a_name = ENV["RESULT_A_NAME"] || RESULT_A_NAME

  @result_b_path = ENV["RESULT_B_PATH"] || RESULT_B_PATH
  @result_b_name = ENV["RESULT_B_NAME"] || RESULT_B_NAME

  @comparison_path = ENV["COMPARISON_PATH"] || COMPARISON_PATH
  @output_path = ENV["OUTPUT_PATH"] || OUTPUT_PATH

  @release_a_name = ENV["RELEASE_A_NAME"] || RELEASE_A_NAME
  @release_a_number = ENV["RELEASE_A_NUMBER"] || RELEASE_A_NUMBER
  @release_a_image = ENV["RELEASE_A_IMAGE"] || RELEASE_A_IMAGE

  @release_b_name = ENV["RELEASE_B_NAME"] || RELEASE_B_NAME
  @release_b_number = ENV["RELEASE_B_NUMBER"] || RELEASE_B_NUMBER
  @release_b_image = ENV["RELEASE_B_IMAGE"] || RELEASE_B_IMAGE
end

def build_report
  # load template
  report = File.read(@template_path)

  # result a
  result_a_table = extract_table_from_csv2html_output(@result_a_path)

  # result b
  result_b_table = extract_table_from_csv2html_output(@result_b_path)

  # comparison
  comparison_table = extract_table_from_csv2html_output(@comparison_path)

  # replace params
  # TODO: iterate a hash of param, replacement

  puts "replacing parameters..."
  puts

  # replace tables first since they may include parameters to replace further down
  report = report.gsub("$RELEASE_A_TABLE", result_a_table)
  report = report.gsub("$RELEASE_B_TABLE", result_b_table)
  report = report.gsub("$COMPARISON_TABLE", comparison_table)

  report = report.gsub("$RELEASE_A_NAME", @release_a_name)
  report = report.gsub("$RELEASE_A_NUMBER", @release_a_number)
  report = report.gsub("$RELEASE_A_IMAGE", @release_a_image)
  report = report.gsub("$RESULT_A_NAME", @result_a_name)

  report = report.gsub("$RELEASE_B_NAME", @release_b_name)
  report = report.gsub("$RELEASE_B_NUMBER", @release_b_number)
  report = report.gsub("$RELEASE_B_IMAGE", @release_b_image)
  report = report.gsub("$RESULT_B_NAME", @result_b_name)

  # write report
  puts "writing report to #{@output_path}"

  File.write(@output_path, report)
end

init
build_report

# rubocop: enable Style/FrozenStringLiteralComment
