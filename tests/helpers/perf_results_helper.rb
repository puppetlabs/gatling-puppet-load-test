# frozen_string_literal: true

require "csv"

# Helper module for the generation of HTML reports from CSV data
# TODO: add spec tests
# TODO: refactor gatling2csv and csv2html POCs
# TODO: consolidate scale results code here
module PerfResultsHelper
  # stats used in gatling2csv
  MAX = "maxResponseTime"
  MEAN = "meanResponseTime"
  STD = "standardDeviation"
  TOTAL = "total"

  PERF_CSV_COLUMN_HEADINGS = ["Duration", "max ms", "mean ms", "std dev"].freeze

  # these must be in the same order as the Gatling data
  PERF_CSV_ROW_LABELS = ["overall response time",
                         "node",
                         "filemeta pluginfacts",
                         "filemeta plugins",
                         "locales",
                         "catalog",
                         "report"].freeze

  # HTML template used in csv2html
  # TODO: use these (and other custom parameterized blocks) in the release report generation scripts?
  HTML_START = <<~HEREDOC
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>Scale Test Results</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>
    </head>
    <body>

    <div class="container">

  HEREDOC

  HTML_END = <<~HEREDOC
    </div>
    </body>
    </html>

  HEREDOC

  # Extract Gatling JSON data into a CSV file in the format used in our release test reports
  #
  # @author Bill Claytor
  #
  # @param [String] results_dir The directory containing the Gatling results from the metrics node
  #
  # @return [void]
  #
  # @example
  #   gatling2csv(results_dir)
  #
  # TODO: refactor into separate methods for extract and output
  # TODO: update scale results handling to use this code
  def gatling2csv(results_dir)
    results_name = File.basename(results_dir)
    output_path = "#{results_dir}/#{results_name}.csv"

    stats_path = "#{results_dir}/js/stats.json"

    puts "Examining Gatling data: #{stats_path}"
    puts

    stats = JSON.parse(File.open(stats_path).read)

    # the 'group' name will be something like 'group_nooptestwithout-9eb19'
    group_keys = stats["contents"].keys.select { |key| key.to_s.match(/group/) }
    raise "JSON parse of #{stats_path} should only result in one key matching 'group'" unless group_keys.length == 1

    group_node = stats["contents"][group_keys[0]]

    # transaction rows are in the 'contents' node
    contents = group_node["contents"]

    # TODO: verify each key
    # TODO: unit test to ensure data validity
    puts "There are #{contents.keys.length} keys"
    puts

    (0..contents.keys.length - 1).each do |i|
      name = contents[contents.keys[i]]["name"]
      puts "key #{i}: #{name}"
    end

    puts "Creating #{output_path}"
    puts

    # TODO: determine and verify values prior to CSV output
    # TODO: unit test to ensure data validity
    CSV.open(output_path, "wb") do |csv|
      # add headings
      csv << PERF_CSV_COLUMN_HEADINGS

      # add rows
      PERF_CSV_ROW_LABELS.each_with_index do |item, index|
        row_data = if index.zero?
                     # overall response time row is in the 'stats' node
                     group_node["stats"]
                   else
                     # individual component rows are in the 'contents' node
                     # offset the index to get the the corresponding key
                     contents[contents.keys[index - 1]]["stats"]
                   end

        csv << [item, row_data[MAX][TOTAL], row_data[MEAN][TOTAL], row_data[STD][TOTAL]]
      end
    end

    csv2html(output_path)
  end

  # Find every CSV file in the specified directory (recursively) and convert each
  # to an HTML file containing a table with the CSV data using a Bootstrap-based template
  #
  # @author Bill Claytor
  #
  # @param [String] scale_results_dir The top-level scale results directory
  #
  # @return [void]
  #
  # @example
  #   scale_results_csv2html(scale_results_dir)
  #
  def scale_results_csv2html(scale_results_dir)
    puts "Converting CSV files to HTML in: #{scale_results_dir}"
    files = Dir.glob("#{scale_results_dir}/**/*.csv")
    files.each do |file|
      csv2html(file)
    end
  end

  # Convert the specified CSV file to an HTML file containing a table
  # with the CSV data using a Bootstrap-based template
  #
  # @author Bill Claytor
  #
  # @param [String] csv_path The path to the CSV file
  #
  # @return [void]
  #
  # @example
  #   csv2html(csv_path)
  #
  def csv2html(csv_path)
    puts "  converting CSV file: #{csv_path}"
    csv_data = CSV.read(csv_path)

    table_start = '  <table class="table table-bordered">'
    tr_start = "    <tr>"
    tr_end = "    </tr>"

    th_start = "      <th>"
    th_end = "</th>"

    td_start = "      <td>"
    td_end = "</td>"

    table_end = "  </table>"
    nl = "\n"

    # start table
    table = table_start + nl

    # start header row
    header_row = tr_start + nl

    # add headers
    csv_data[0].each do |field|
      header = th_start + field + th_end + nl
      header_row += header
    end

    # finish header row
    header_row = header_row + tr_end + nl

    # add header row to table
    table += header_row

    # add rows
    (1..csv_data.length - 1).each do |ct|
      # start row
      current_row = tr_start + nl

      # add cells
      csv_data[ct].each do |field|
        cell = "#{td_start}#{field}#{td_end}" + nl
        current_row += cell
      end

      # end row
      current_row = current_row + tr_end + nl

      # add row
      table += current_row
    end

    # end table
    table = table + table_end + nl

    # create HTML doc
    heading = "  <h2>#{File.basename(csv_path)}</h2>" + nl
    html = HTML_START + heading + table + HTML_END
    html_path = "#{csv_path}.html"

    puts "  creating HTML file: #{html_path}"
    puts

    File.write(html_path, html)
  end

  # Extract the HTML table from the csv2html output
  # so it can be used in template-based release reports
  #
  # @author Bill Claytor
  #
  # @param [String] html_path The path to the csv2html formatted HTML file
  #
  # @return [String] The HTML table
  #
  # @example
  #   results_table = extract_table_from_csv2html_output(html_path)
  #
  def extract_table_from_csv2html_output(html_path)
    puts "extracting table from #{html_path}"
    puts

    html_string = File.read(html_path)
    table_string = "".dup
    table_start = false

    html_string.each_line do |line|
      table_start = true if line.include?("<table")

      table_string << line if table_start

      break if line.include?("</table>")
    end

    table_string
  end

  # Splits the specified atop summary CSV file generated by beaker-benchmark
  # into separate CSV files for the summary and detail
  # so they can be converted into HTML tables using csv2html
  # and used in release reports
  #
  # @author Bill Claytor
  #
  # @param [String] csv_path The path to the atop csv file
  #
  # @return [void]
  #
  # @example
  #   split_atop_csv(csv_path)
  #
  # TODO: eliminate the need for this by generating separate csv files after the run
  #
  def split_atop_csv_results(csv_path)
    puts "processing CSV file: #{csv_path}"
    output_path_summary = csv_path.gsub(".csv", ".summary.csv")
    output_path_detail = csv_path.gsub(".csv", ".detail.csv")

    output_path = output_path_summary

    contents = File.read(csv_path)

    puts "creating summary: #{output_path_summary}"
    File.open(output_path_summary, "w")

    puts "creating detail: #{output_path_detail}"
    File.open(output_path_detail, "w")

    line_ct = 0
    contents.each_line do |line|
      line_ct += 1

      output_path = output_path_detail if line_ct > 3

      File.open(output_path, "a") do |f|
        f.puts line
      end
    end

    # csv2html
    puts "converting CSV files to HTML:"
    csv2html(output_path_summary)
    csv2html(output_path_detail)
  end

  # Create comparison CSV and HTML files for the summary (working) and detail (TBD)
  # sections of the specified beaker-benchmark atop CSV report
  #
  # @author Bill Claytor
  #
  # @param [String] csv_path_a The baseline atop CSV file
  # @param [String] csv_path_b The SUT atop CSV file
  # @param [String] comparison_path The output path for the comparison file(s)
  #
  # @return [void]
  #
  # @example
  #   output = method(arg)
  #
  def compare_atop_csv_results(csv_path_a, csv_path_b, comparison_path)
    split_atop_csv_results(csv_path_a)
    split_atop_csv_results(csv_path_b)

    summary_path_a = csv_path_a.gsub(".csv", ".summary.csv")
    summary_path_b = csv_path_b.gsub(".csv", ".summary.csv")
    summary_comparison_path = comparison_path.gsub(".csv", ".summary.csv")

    detail_path_a = csv_path_a.gsub(".csv", ".detail.csv")
    detail_path_b = csv_path_b.gsub(".csv", ".detail.csv")
    detail_comparison_path = comparison_path.gsub(".csv", ".detail.csv")

    compare_atop_summary(summary_path_a, summary_path_b, summary_comparison_path)
    compare_atop_detail(detail_path_a, detail_path_b, detail_comparison_path)
  end

  # Create comparison CSV and HTML files for the summary
  # sections of the specified beaker-benchmark atop CSV report
  #
  # @author Bill Claytor
  #
  # @param [String] csv_path_a The baseline atop summary CSV file
  # @param [String] csv_path_b The SUT atop summary CSV file
  # @param [String] comparison_path The output path for the summary comparison file(s)
  #
  # @return [void]
  #
  # @example
  #   compare_atop_summary(csv_path_a, csv_path_b, comparison_path)
  #
  def compare_atop_summary(csv_path_a, csv_path_b, comparison_path)
    puts "Comparing #{csv_path_a} and #{csv_path_b}"
    puts "Creating #{comparison_path}"

    result_a = CSV.read(csv_path_a)
    result_b = CSV.read(csv_path_b)

    CSV.open(comparison_path.to_s, "wb") do |csv|
      csv << ["", "$RESULT_A", "$RESULT_B", "% diff"]

      action_a = result_a[1][0]
      duration_a = result_a[1][1]
      cpu_a = result_a[1][2]
      mem_a = result_a[1][3]
      dr_a = result_a[1][4]
      dw_a = result_a[1][5]

      action_b = result_b[1][0]
      duration_b = result_b[1][1]
      cpu_b = result_b[1][2]
      mem_b = result_b[1][3]
      dr_b = result_b[1][4]
      dw_b = result_b[1][5]

      csv << ["Action", action_a, action_b, "N/A"]
      csv << ["Duration", duration_a, duration_b, percent_diff_string(duration_a, duration_b)]
      csv << ["Avg CPU", cpu_a, cpu_b, percent_diff_string(cpu_a, cpu_b)]
      csv << ["Avg MEM", mem_a, mem_b, percent_diff_string(mem_a, mem_b)]
      csv << ["Avg DSK read", dr_a, dr_b, percent_diff_string(dr_a, dr_b)]
      csv << ["Avg DSK Write", dw_a, dw_b, percent_diff_string(dw_a, dw_b)]
    end

    csv2html(comparison_path)
  end

  # Create comparison CSV and HTML files for the detail
  # sections of the specified beaker-benchmark atop CSV report
  #
  # @author Bill Claytor
  #
  # @param [String] csv_path_a The baseline atop detail CSV file
  # @param [String] csv_path_b The SUT atop detail CSV file
  # @param [String] comparison_path The output path for the detail comparison file(s)
  #
  # @return [void]
  #
  # @example
  #   compare_atop_detail(csv_path_a, csv_path_b, comparison_path)
  #
  # TODO: get this working
  def compare_atop_detail(csv_path_a, csv_path_b, comparison_path)
    # puts "Comparing #{csv_path_a} and #{csv_path_b}"
    # puts "Creating #{comparison_path}"

    # result_a = CSV.read(csv_path_a)
    # result_b = CSV.read(csv_path_b)
  end

  # Calculate the percentage difference between the specified perf result values
  # and return the rounded result
  #
  # @author Bill Claytor
  #
  # @param [String] result_a The baseline value
  # @param [String] result_b The comparison value
  #
  # @return [Float] The rounded result
  #
  # @example
  #   diff = percent_diff(result_a, result_b)
  #
  def percent_diff(result_a, result_b)
    result = ((result_b.to_f - result_a.to_f) / result_a.to_f) * 100
    result.round(2)
  end

  # Call percent_diff and return the result as a string formatted with a %
  #
  # @author Bill Claytor
  #
  # @param [String] result_a The baseline value
  # @param [String] result_b The comparison value
  #
  # @return [String] The result of percent_diff as a string formatted with a %
  #
  # @example
  #   diff_string = percent_diff_string(result_a, result_b)
  #
  def percent_diff_string(result_a, result_b)
    "#{percent_diff(result_a, result_b)}%"
  end
end
