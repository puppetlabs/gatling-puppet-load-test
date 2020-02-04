# frozen_string_literal: true

require "../../tests/helpers/perf_results_helper.rb"
include PerfResultsHelper # rubocop:disable Style/MixinUsage

TEMPLATE_PATH = "./templates/scale_csv_summary_template.html"

SUMMARY_CSV_HEADINGS = ["result",
                        "agents",
                        "ok",
                        "ko",
                        "combined mean",
                        "catalog mean",
                        "filemeta plugins mean",
                        "filemeta pluginfacts mean",
                        "locales mean",
                        "node mean",
                        "report mean",
                        "average CPU %",
                        "average memory"].freeze

@template_path = ENV["TEMPLATE_PATH"] || TEMPLATE_PATH
@tables = ""

# Build the scale test summary using the default or specified template
# note: the template can be specified via the TEMPLATE_PATH environment variable
#
# @author Bill Claytor
#
# @param [String] parent_dir The parent directory containing the scale test result directories
#
# @return [void]
#
# @example
#   build_report(parent_dir)
#
def build_scale_csv_summary(parent_dir)
  puts "building scale test csv summary report for parent dir: #{parent_dir}"
  puts

  parent_name = File.basename(parent_dir)
  output_path = "#{parent_dir}/#{parent_name}.html"

  # create a summary csv file to contain the last successful iteration from each result
  @summary_csv_path_success = "#{parent_dir}/#{parent_name}.summary_success.csv"
  create_summary_csv(@summary_csv_path_success)

  # create a summary csv file to contain the failing iteration from each result
  @summary_csv_path_fail = "#{parent_dir}/#{parent_name}.summary_fail.csv"
  create_summary_csv(@summary_csv_path_fail)

  # start with the template
  report = File.read(@template_path)

  # process each result dir
  process_result_dirs(parent_dir)

  # calculate variance for success
  calculate_summary_csv(@summary_csv_path_success)

  # calculate variance for failure
  calculate_summary_csv(@summary_csv_path_fail)

  # csv2html
  csv2html(@summary_csv_path_success)
  csv2html(@summary_csv_path_fail)

  # result name
  report = report.gsub("$RESULT_NAME", parent_name)

  # add summary success table
  summary_success_table = extract_table_from_csv2html_output("#{@summary_csv_path_success}.html")
  report = report.gsub("$RESULT_SUMMARY_SUCCESS_TABLE", summary_success_table)

  # add summary fail table
  summary_fail_table = extract_table_from_csv2html_output("#{@summary_csv_path_fail}.html")
  report = report.gsub("$RESULT_SUMMARY_FAIL_TABLE", summary_fail_table)

  # add extract tables
  report = report.gsub("$RESULT_EXTRACT_TABLES", @tables)

  # write report
  puts "writing report to #{output_path}"
  puts

  File.write(output_path, report)
end

# Create the summary CSV file
#
# @author Bill Claytor
#
# @param [String] summary_csv_path The summary CSV file path
#
# @return [void]
#
# @example
#   create_summary_csv(summary_csv_path)
#
def create_summary_csv(summary_csv_path)
  puts "creating summary csv: #{summary_csv_path}"

  CSV.open(summary_csv_path, "wb") do |csv|
    csv << SUMMARY_CSV_HEADINGS
  end
end

# Extract data from each result dir in the parent dir to build the report
#
# @author Bill Claytor
#
# @param [String] parent_dir The parent directory containing the scale test result directories
#
# @return [void]
#
# @example
#    process_result_dirs(parent_dir)
#
def process_result_dirs(parent_dir)
  # get all the result dirs in the parent dir
  results_dirs = Dir.glob("#{parent_dir}/*/").sort
  puts "processing #{results_dirs.length} results directories..."

  # process each result dir
  results_dirs.each do |dir|
    dirname = File.basename(dir)
    puts "processing results dir: #{dirname}"

    csv_path = "#{dir}#{dirname}.csv"
    puts "csv_path: #{csv_path}"

    # create a summary csv with the headings and last 2 rows
    heading = "<h1>#{dirname}</h1>"
    table = process_results_csv(csv_path)
    @tables += heading + table unless table.nil?
  end
end

# Extract data from the specified scale test results CSV file
#
# @author Bill Claytor
#
# @param [String] csv_path The scale test results CSV file path
#
# @return [String] The CSV data converted to an HTML table
#
# @example
#    table = process_results_csv(csv_path)
#
def process_results_csv(csv_path)
  # ensure the expected result csv file exists
  raise "File not found: #{csv_path}" unless File.file?(csv_path)

  # create a csv file with the headings and last 2 rows
  output_path = csv_path.gsub(".csv", ".scale_extract.csv")
  csv_name = File.basename(csv_path)
  result_name = csv_name.gsub(".csv", "")
  puts "processing csv: #{csv_name}"

  # TODO: extract into a separate method?
  contents = File.readlines(csv_path)

  # only include runs that didn't fail on the first iteration
  if contents.length > 2
    File.open(output_path, "w") do |f|
      f << contents[0]
      f << contents[-2]
      f << contents[-1]
    end

    # add the 2nd to last line to the success summary
    update_summary_csv(@summary_csv_path_success, "#{result_name},#{contents[-2]}")

    # add the last line to the fail summary
    update_summary_csv(@summary_csv_path_fail, "#{result_name},#{contents[-1]}")

    # csv2html
    csv2html(output_path)

    # table
    table = extract_table_from_csv2html_output("#{output_path}.html")

  else
    puts "This run failed on the first iteration; ignoring..."
    puts
    table = nil
  end

  table
end

# Add a new row the the specified summary CSV file
#
# @author Bill Claytor
#
# @param [String] summary_csv_path The summary CSV file path
# @param [String] line The line to add to the CSV file
#
# @return [void]
#
# @example
#    update_summary_csv(summary_csv_path, line)
#
def update_summary_csv(summary_csv_path, line)
  puts "updating summary csv: #{summary_csv_path}"
  puts "results: #{line}"

  # the results row is a string rather than an array so handle as file rather than csv
  File.open(summary_csv_path, "a+") do |f|
    f << line
  end
end

# Update the summary CSV with the mean and standard deviation for each column
#
# @author Bill Claytor
#
# @param [String] summary_csv_path The summary CSV file path
#
# @return [void]
#
# @example
#    calculate_summary_csv(summary_csv_path)
#
def calculate_summary_csv(summary_csv_path)
  puts "calculating variance for summary csv: #{summary_csv_path}"

  csv_data = CSV.read(summary_csv_path)
  number_of_rows = csv_data.length - 1
  mean_row = ["mean:"]
  std_row = ["std dev:"]

  # each column
  (1..SUMMARY_CSV_HEADINGS.length - 1).each do |column_ct|
    column_array = []

    # process rows
    (1..number_of_rows).each do |row_ct|
      value = csv_data[row_ct][column_ct].to_i
      column_array << value
    end

    # mean
    mean_row << mean(column_array).round(2)

    # std dev
    std_row << sigma(column_array).round(2)
  end

  # add rows
  CSV.open(summary_csv_path, "a+") do |csv|
    csv << mean_row
    csv << std_row
  end
end

# Calculate the mean for the specified array
#
# @author Bill Claytor
#
# @param [Array] array The array to use for the calculation
#
# @return [Float] The mean
#
# @example
#    value = mean(array)
#
def mean(array)
  total = 0.0
  array.each do |value|
    total += value
  end
  total / array.size
end

# Calculate the variance for the specified array
#
# based on "Variance and Standard Deviation":
# https://www.oreilly.com/library/view/the-ruby-way/0768667208/0768667208_ch05lev1sec26.html
#
# @author Bill Claytor
#
# @param [Array] array The array to use for the calculation
#
# @return [Float] The variance
#
# @example
#    value = variance(array)
#
def variance(array)
  arr_mean = mean(array)
  sum = 0.0
  array.each { |value| sum += (value - arr_mean)**2 }
  sum / array.size
end

# Calculate the standard deviation for the specified array
#
# based on "Variance and Standard Deviation":
# https://www.oreilly.com/library/view/the-ruby-way/0768667208/0768667208_ch05lev1sec26.html
#
# @author Bill Claytor
#
# @param [Array] array The array to use for the calculation
#
# @return [Float] The standard deviation
#
# @example
#    value = sigma(array)
#
def sigma(array)
  Math.sqrt(variance(array))
end

raise Exception, "you must provide a results directory" unless ARGV[0]

parent_dir = ARGV[0]
build_scale_csv_summary(parent_dir) if $PROGRAM_NAME == __FILE__
