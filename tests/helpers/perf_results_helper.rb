# frozen_string_literal: true

require "csv"

# TODO: refactor csv2html POC and add spec tests
# TODO: consolidate scale results code here
# Helper module for the generation of HTML reports from CSV data
module PerfResultsHelper
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

  def scale_results_csv2html(scale_results_dir)
    puts "Converting CSV files to HTML in: #{scale_results_dir}"
    files = Dir.glob("#{scale_results_dir}/**/*.csv")
    files.each do |file|
      csv2html(file)
    end
  end

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
end
