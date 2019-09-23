# frozen_string_literal: true

require "csv"
require "json"
require "minitar"
require "zlib"

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
  CSV_HTML_START = <<~CSV_HTML_START
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>CSV2HTML</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>
    </head>
    <body>

    <div class="container">

  CSV_HTML_START

  CSV_HTML_END = <<~CSV_HTML_END
    </div>
    </body>
    </html>

  CSV_HTML_END

  PMC_ROW_HEADINGS = ["file",
                      "timestamp",
                      "static compile (mean)",
                      "average borrow time",
                      "num free jrubies"].freeze

  STATS_JSON_STAT_NAMES = ["node",
                           "filemeta pluginfacts",
                           "filemeta plugins",
                           "locales",
                           "catalog",
                           "report"].freeze

  # TODO: update to 'puppet-metrics-collector' (SLV-589)
  PUPPET_METRICS_COLLECTOR_DIR_NAME = "puppet_metrics_collector"

  # Extract Gatling JSON data into a CSV file in the format used in our release test reports
  # and convert the CSV file to an HTML file for easy viewing
  #
  # @author Bill Claytor
  #
  # @param [String] results_dir The directory containing the Gatling results from the metrics node
  # @param [String] output_dir The directory where the output CSV and HTML fileS should be written
  #
  # @return [void]
  #
  # @example
  #   gatling2csv(results_dir)
  #
  # TODO: refactor into separate methods for extract and output
  # TODO: update scale results handling to use this code
  def gatling2csv(results_dir, output_dir = results_dir)
    raise "Invalid results_dir: #{results_dir}" unless File.directory?(results_dir)

    results_name = File.basename(results_dir)
    output_path = "#{output_dir}/#{results_name}.csv"
    stats_path = "#{results_dir}/js/stats.json"

    # transaction rows are in the 'contents' node
    group_node = gatling_json_stats_group_node(stats_path)
    contents = gatling_json_stats_group_node_contents(group_node)

    puts "Creating #{output_path}"
    puts

    # TODO: determine and verify values prior to CSV output
    # TODO: unit test to ensure data validity
    # TODO: extract to a separate method
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

  # Parse the stats.json file and return the group node
  #
  # @author Bill Claytor
  #
  # @param [String] stats_path The path to the stats.json file
  #
  # @raise [StandardError] If the specified file is not found
  # @raise [StandardError] If the specified file does not contain the group node
  #
  # @return [JSON] The group node
  #
  # @example
  #   group_node = gatling_json_stats_group_node(stats_path)
  #
  def gatling_json_stats_group_node(stats_path)
    raise "The specified file was not found: #{stats_path}" unless File.exist?(stats_path)

    puts "Examining Gatling data: #{stats_path}"
    puts

    begin
      # the 'group' name will be something like 'group_nooptestwithout-9eb19'
      stats = JSON.parse(File.open(stats_path).read)
      group_keys = stats["contents"].keys.select { |key| key.to_s.match(/group/) }
      group_node = stats["contents"][group_keys[0]]
    rescue StandardError
      raise "JSON parse of #{stats_path} should result in one key matching 'group'"
    end

    group_node
  end

  # Retrieves the contents from the group node
  #
  # @author Bill Claytor
  #
  # @param [JSON] group_node The group node
  #
  # @raise [StandardError] If the group node does not contain contents with more than one key
  #
  # @return [JSON] The contents
  #
  # @example
  #   contents = gatling_json_stats_group_node_contents(group_node)
  #
  def gatling_json_stats_group_node_contents(group_node)
    contents = group_node["contents"]

    if contents.nil? || contents.empty? || contents.keys.empty? || contents.keys.length < STATS_JSON_STAT_NAMES.length
      raise "The 'contents' element of the 'group' node must have at least #{STATS_JSON_STAT_NAMES.length} keys"
    end

    # build an array of the stat names to compare with the expected names
    contents_stat_names = []
    (0..contents.keys.length - 1).each do |i|
      contents_stat_names << contents[contents.keys[i]]["name"]
    end

    # check each expected stat name
    STATS_JSON_STAT_NAMES.each do |name|
      raise "Stat name '#{name}' not found" unless contents_stat_names.include?(name)
    end

    contents
  end

  # Find every CSV file in the specified directory (recursively) and convert each
  # to an HTML file containing a table with the CSV data using a Bootstrap-based template
  #
  # @author Bill Claytor
  #
  # @param [String] dir The directory to process
  #
  # @return [void]
  #
  # @example
  #   csv2html_directory(dir)
  #
  def csv2html_directory(dir)
    raise "Invalid directory: #{dir}" unless File.directory?(dir)

    puts "Converting CSV files to HTML in: #{dir}"

    files = Dir.glob("#{dir}/**/*.csv")
    raise "No CSV files found in directory: #{dir}" if files.empty?

    files.each do |file|
      begin
        csv2html(file)
      rescue StandardError
        puts "Invalid CSV file: #{file}"
        puts
      end
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
    validate_csv(csv_path)

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
    html = CSV_HTML_START + heading + table + CSV_HTML_END
    html_path = "#{csv_path}.html"

    puts "  creating HTML file: #{html_path}"
    puts

    File.write(html_path, html)
  end

  # Average each column of the specified CSV file
  # and create a new CSV file with the averages
  #
  # @author Bill Claytor
  #
  # @param [String] data_csv_path The path to the CSV file
  # @param [Integer] start_column The column index to start computing averages
  #
  # @return [void]
  #
  # @example
  #   average_csv(data_csv_path)
  #   average_csv(data_csv_path, 1)
  #
  # TODO: error handling, spec test
  #
  def average_csv(data_csv_path, start_column = 0)
    validate_csv(data_csv_path)

    puts "Reading CSV file: #{data_csv_path}"
    data_csv = CSV.read(data_csv_path)
    num_rows = data_csv.length - 1

    raise "The specified CSV file contains no data: #{data_csv_path}" unless num_rows > 1

    headings_row = []
    averages_row = []
    average_csv_path = data_csv_path.gsub(".csv", ".average.csv")

    # headings
    (start_column..(data_csv[0].length - 1)).each do |col_index|
      headings_row << data_csv[0][col_index]
    end

    # average each column
    (start_column..(data_csv[0].length - 1)).each do |col_index|
      total = 0

      # add each row
      (1..data_csv.length - 1).each do |row_ct|
        value = data_csv[row_ct][col_index].to_f
        total += value
      end

      # only average if the total is > 0 (TODO: ?)
      average = if total.positive?
                  total / num_rows
                else
                  0
                end

      averages_row << average.round(2)
    end

    CSV.open(average_csv_path.to_s, "wb") do |average_csv|
      average_csv << headings_row
      average_csv << averages_row
    end
  end

  # Validate the specified CSV file using csvlint
  #
  # @author Bill Claytor
  #
  # @param [String] csv_path The path to the CSV file
  #
  # @raise [StandardError] If the file is not found
  # @raise [StandardError] If the validation fails
  #
  # @return [Boolean] true if the file is valid
  #
  # @example
  #   validate_csv(csv_path)
  #
  def validate_csv(csv_path)
    raise "File not found: #{csv_path}" unless File.exist?(csv_path)

    raise "Not a CSV file: #{csv_path}" unless File.extname(csv_path).eql?(".csv")

    csv_data = CSV.read(csv_path)

    # validate
    valid = true
    valid = false unless csv_data.length >= 2
    num_headings = csv_data[0].length
    (1..csv_data.length - 1).each do |ct|
      num_columns = csv_data[ct].length
      valid = false unless num_columns == num_headings
    end

    # check validation status
    raise "Invalid CSV file: #{csv_path}" unless valid

    valid
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
    raise "File not found: #{html_path}" unless File.exist?(html_path)

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

    raise "HTML table not found in file: #{html_path}" if table_string.empty?

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
      line.rstrip!
      next if line.empty?

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

  # Extracts the following data from the specified 'puppet-metrics-collector' directory:
  #   timestamp, static_compile_mean, average_borrow_time, num_free_jrubies
  #
  # @author Bill Claytor
  #
  # @param [String] metrics_dir_or_tar_file The 'puppet-metrics-collector' directory
  #   or gzipped tar file
  #
  # @return [void]
  #
  # @example
  #   extract_puppet_metrics_collector_data(metrics_dir_or_tar_file)
  #
  def extract_puppet_metrics_collector_data(metrics_dir_or_tar_file)
    raise "File not found: #{metrics_dir_or_tar_file}" unless File.exist?(metrics_dir_or_tar_file)

    if File.directory?(metrics_dir_or_tar_file)
      puppet_metrics_dir = metrics_dir_or_tar_file
    else
      puts "Specified path is not a directory; verifying file..."
      parent_dir = File.dirname(metrics_dir_or_tar_file)
      extract_tgz(metrics_dir_or_tar_file)
      puppet_metrics_dir = "#{parent_dir}/#{PUPPET_METRICS_COLLECTOR_DIR_NAME}"
    end

    puts "Extracting metrics data from: #{puppet_metrics_dir}"
    puts

    # TODO: process other service files
    extract_puppetserver_metrics(puppet_metrics_dir)
  end

  # Extracts the specified gzipped tar file to the specified directory
  #
  # @author Bill Claytor
  #
  # @param [String] src The gzipped tar file path
  # @param [String] dest The destination directory
  #
  # @return [void]
  #
  # @example
  #   extract_tgz(src, dest)
  #
  def extract_tgz(src, dest = File.dirname(src))
    options = ["file", "--brief", "--mime-type", src]
    mime_type = IO.popen(options, in: :close, err: :close).read.chomp
    error_msg = "Invalid mime type '#{mime_type}' for file: #{src}"
    raise error_msg unless mime_type.include?("gzip")

    tgz = Zlib::GzipReader.new(File.open(src, "rb"))
    Archive::Tar::Minitar.unpack(tgz, dest)
  end

  # Processes the files in the 'puppetserver' service directory:
  # - extracts the JSON parameters
  # - creates the output CSV file
  # - creates the averages CSV file
  # - converts the CSV files to HTML for use in reports
  #
  # @author Bill Claytor
  #
  # @param [String] metrics_dir The 'puppet-metrics-collector' directory
  #
  # @return [void]
  #
  # @example
  #   extract_puppetserver_metrics(metrics_dir)
  #
  # TODO: refactor to be generic
  def extract_puppetserver_metrics(metrics_dir)
    puppetserver_dir = "#{metrics_dir}/puppetserver"
    raise "Directory not found: #{puppetserver_dir}" unless File.directory?(puppetserver_dir)

    puts
    puts "Extracting puppetserver data from: #{metrics_dir}/puppetserver"
    puts

    puppetserver_files = Dir.glob("#{metrics_dir}/puppetserver/**/*.json")
    raise "No JSON files found: #{puppetserver_dir}" if puppetserver_files.nil? || puppetserver_files.empty?

    csv_path = "#{metrics_dir}/../puppetserver.csv"
    CSV.open(csv_path, "wb") do |csv|
      csv << PMC_ROW_HEADINGS

      puppetserver_files.sort.each do |file|
        puppetserver_metrics = extract_puppetserver_metrics_from_json(file)
        csv << puppetserver_metrics unless puppetserver_metrics.nil?
      end
    end

    average_csv(csv_path, 2)
    csv2html(csv_path)
    csv2html(csv_path.gsub(".csv", ".average.csv"))
  end

  # Processes the specified JSON file in the 'puppetserver' service directory
  #
  # @author Bill Claytor
  #
  # @param [String] file The JSON file to process
  #
  # @return [Array] The parameters array / csv row
  #
  # @example
  #   extract_puppetserver_metrics_from_json(file)
  #
  # rubocop:disable Metrics/LineLength
  def extract_puppetserver_metrics_from_json(file)
    raise "The specified file was not found: #{file}" unless File.exist?(file)

    puts "Processing file: #{file}"
    row = nil

    contents = File.read(file)
    json = JSON.parse(contents)

    begin
      timestamp = json["timestamp"]

      # catalog (ignore metrics without catalog metrics)
      # TODO: investigate alternatives to handling averages
      # TODO: update to use dig, handle multiple puppetservers (https://tickets.puppetlabs.com/browse/SLV-569)
      catalog_metrics = json["servers"][json["servers"].keys[0]]["puppetserver"]["pe-puppet-profiler"]["status"]["experimental"]["catalog-metrics"]

      # catalog
      static_compile_mean = catalog_metrics[0]["mean"]

      # jruby
      pe_jruby_metrics = json["servers"][json["servers"].keys[0]]["puppetserver"]["pe-jruby-metrics"]["status"]["experimental"]["metrics"]
      average_borrow_time = pe_jruby_metrics["average-borrow-time"]
      num_free_jrubies = pe_jruby_metrics["num-free-jrubies"]

      row = [File.basename(file), timestamp, static_compile_mean, average_borrow_time, num_free_jrubies]
    rescue StandardError
      puts "JSON does not contain catalog metrics; ignoring..."
      puts
    end

    row
  end
  # rubocop:enable Metrics/LineLength
end
