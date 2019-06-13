# rubocop: disable Style/FrozenStringLiteralComment

TEMPLATE_PATH = "templates/perf_comparison_template.html".freeze

RESULT_COMPARISON_PATH = "examples/perf_comparison_template_defaults/perf_comparison_a_vs_b.csv.html".freeze

# rubocop: disable Metrics/LineLength
ATOP_SUMMARY_COMPARISON_PATH = "examples/perf_comparison_template_defaults/atop_comparison_a_vs_b.summary.csv.html".freeze
# rubocop: enable Metrics/LineLength

RESULT_A = "PerfTestLarge-12345678".freeze
RELEASE_A_NAME = "Release A".freeze
RELEASE_A_NUMBER = "1.2.3".freeze

RESULT_B = "PerfTestLarge-23456789".freeze
RELEASE_B_NAME = "Release B".freeze
RELEASE_B_NUMBER = "2.3.4".freeze

OUTPUT_PATH = "examples/example_perf_comparison_report.html".freeze

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

# TODO: move to perf_results_helper
def extract_table(html_path)
  puts "extracting table from #{html_path}"
  puts

  html_string = File.read(html_path)
  table_string = ""
  table_start = false

  html_string.each_line do |line|
    table_start = true if line.include?("<table")

    table_string << line if table_start

    break if line.include?("</table>")
  end

  table_string
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

def build_report
  puts "building report..."
  puts

  # load template
  report = File.read(@template_path)

  # metrics result
  result_comparison_table = extract_table(@result_comparison_path)

  # atop summary
  atop_summary_comparison_table = extract_table(@atop_summary_comparison_path)

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

# rubocop: enable Style/FrozenStringLiteralComment
