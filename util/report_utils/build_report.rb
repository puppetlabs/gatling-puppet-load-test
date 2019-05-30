# TODO: include this functionality in every performance run
# TODO: extract result names from path

# raise Exception, 'you must provide a results directory' unless ARGV[0]
# arg_0 = ARGV[0]

TEMPLATE_PATH = "./soak_results_template.html"

RESULT_A_PATH = "examples/template/PerfTestLarge-A.csv.html"
RESULT_A_NAME = "PerfTestLarge-12345678"

RESULT_B_PATH = "examples/template/PerfTestLarge-B.csv.html"
RESULT_B_NAME = "PerfTestLarge-23456789"

COMPARISON_PATH = "examples/template/PerfTestLarge-A_vs_PerfTestLarge-B.csv.html"
OUTPUT_PATH = "./example_soak_report.html"

RELEASE_A_NAME = "RELEASE A"
RELEASE_A_NUMBER = "1.2.3"
RELEASE_A_IMAGE = "examples/template/release_a.png"

RELEASE_B_NAME = "RELEASE B"
RELEASE_B_NUMBER = "2.3.4"
RELEASE_B_IMAGE = "examples/template/release_b.png"

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

# TODO: refactor
def extract_table(html_path)
  puts "extracting table from #{html_path}"
  puts

  html_string = File.read(html_path)
  table_string = ""
  table_start = false

  html_string.each_line do |line|

    if line.include?("<table")
      table_start = true
    end

    if table_start
      table_string << line
    end

    if line.include?("</table>")
      break
    end

  end

  return table_string

end

# load template
report = File.read(@template_path)

# result a
result_a_table = extract_table(@result_a_path)

# result b
result_b_table = extract_table(@result_b_path)

# comparison
comparison_table = extract_table(@comparison_path)

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
