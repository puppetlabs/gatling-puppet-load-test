# rubocop: disable Style/FrozenStringLiteralComment

# TODO: move to perf_results_helper
# TODO: include this functionality in every performance run
# TODO: extract result names from path

TEMPLATE_PATH = "templates/perf_results_template.html".freeze

RESULT_PATH = "examples/perf_template_defaults/PerfTestLarge-A.csv.html".freeze
RESULT_NAME = "PerfTestLarge-12345678".freeze

OUTPUT_PATH = "examples/example_perf_report.html".freeze

RELEASE_NUMBER = "1.2.3".freeze
RESULT_IMAGE = "perf_template_defaults/release_a.png".freeze

ATOP_SUMMARY_PATH = "examples/perf_template_defaults/atop_log_applestoapples_json.summary.csv.html".freeze
ATOP_DETAIL_PATH = "examples/perf_template_defaults/atop_log_applestoapples_json.detail.csv.html".freeze

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

  report = report.gsub("$RELEASE_NUMBER", @release_number)
  report = report.gsub("$RESULT_IMAGE", @result_image)
  report = report.gsub("$RESULT_NAME", @result_name)

  report
end

def build_report
  puts "building report..."
  puts

  # load template
  report = File.read(@template_path)

  # metrics result
  result_table = extract_table(@result_path)

  # atop summary
  atop_summary_table = extract_table(@atop_summary_path)

  # atop detail
  atop_detail_table = extract_table(@atop_detail_path)

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

# rubocop: enable Style/FrozenStringLiteralComment
