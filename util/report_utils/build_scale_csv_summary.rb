# rubocop: disable Style/FrozenStringLiteralComment

require "../../tests/helpers/perf_results_helper.rb"
include PerfResultsHelper # rubocop:disable Style/MixinUsage

raise Exception, "you must provide a results directory" unless ARGV[0]

parent_dir = ARGV[0]

TEMPLATE_PATH = "./templates/scale_csv_summary_template.html".freeze

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

def process_results_csv(csv_path, summary_csv_path)
  # ensure the expected result csv file exists
  raise "File not found: #{csv_path}" unless File.file?(csv_path)

  # create a csv file with the headings and last 2 rows
  output_path = csv_path.gsub(".csv", ".scale_extract.csv")
  csv_name = File.basename(csv_path)
  result_name = csv_name.gsub(".csv", "")
  puts "processing csv: #{csv_name}"

  # TODO: extract into a separate method?
  contents = File.readlines(csv_path)
  File.open(output_path, "w") do |f|
    f << contents[0]
    f << contents[contents.length - 2]
    f << contents[contents.length - 1]
  end

  # add the 2nd to last line to the summary
  line = contents[contents.length - 2]
  update_summary_csv(summary_csv_path, "#{result_name},#{line}")

  # csv2html
  csv2html(output_path)

  # table
  table = extract_table("#{output_path}.html")

  table
end

def create_summary_csv(summary_csv_path)
  puts "creating summary csv: #{summary_csv_path}"

  CSV.open(summary_csv_path, "wb") do |csv|
    csv << SUMMARY_CSV_HEADINGS
  end
end

def update_summary_csv(summary_csv_path, line)
  puts "updating summary csv: #{summary_csv_path}"
  puts "results: #{line}"

  # the results row is a string rather than an array so handle as file rather than csv
  File.open(summary_csv_path, "a+") do |f|
    f << line
  end
end

def average_summary_csv(summary_csv_path)
  puts "calculating averages for summary csv: #{summary_csv_path}"

  csv_data = CSV.read(summary_csv_path)
  number_of_rows = csv_data.length - 1
  averages_row = ["average:"]

  # each column
  (1..SUMMARY_CSV_HEADINGS.length - 1).each do |column_ct|
    column_total = 0

    # process rows
    (1..number_of_rows).each do |row_ct|
      # get value
      value = csv_data[row_ct][column_ct].to_i

      # add
      column_total += value
    end

    # average
    column_average = column_total / number_of_rows
    averages_row << column_average
  end

  # add averages row
  CSV.open(summary_csv_path, "a+") do |csv|
    csv << averages_row
  end
end

def build_report(parent_dir)
  puts "building report for parent dir: #{parent_dir}"
  puts

  parent_name = File.basename(parent_dir)
  output_path = "#{parent_dir}/#{parent_name}.html"

  # create a summary csv file to contain the last successful iteration from each result
  summary_csv_path = "#{parent_dir}/#{parent_name}.summary.csv"
  create_summary_csv(summary_csv_path)

  # start with the template
  report = File.read(@template_path)
  tables = ""

  # get all the result dirs in the results dir
  # Dir.chdir(parent_dir)
  results_dirs = Dir.glob("#{parent_dir}/*/").sort
  num_results_dirs = results_dirs.length

  puts "processing #{num_results_dirs} results directories..."

  # process each result dir
  results_dirs.each do |dir|
    dirname = File.basename(dir)
    puts "processing results dir: #{dirname}"

    csv_path = "#{dir}#{dirname}.csv"
    puts "csv_path: #{csv_path}"

    # create a summary csv with the headings and last 2 rows
    heading = "<h1>#{dirname}</h1>"
    table = process_results_csv(csv_path, summary_csv_path)
    tables += heading + table
  end

  # calculate averages
  average_summary_csv(summary_csv_path)

  # csv2html
  csv2html(summary_csv_path)

  # extract summary table
  summary_table = extract_table("#{summary_csv_path}.html")

  # result name
  report = report.gsub("$RESULT_NAME", parent_name)

  # add summary table
  report = report.gsub("$RESULT_SUMMARY_TABLE", summary_table)

  # add extract tables
  report = report.gsub("$RESULT_EXTRACT_TABLES", tables)

  # write report
  puts "writing report to #{output_path}"
  puts

  File.write(output_path, report)
end

build_report(parent_dir)

# rubocop: enable Style/FrozenStringLiteralComment
