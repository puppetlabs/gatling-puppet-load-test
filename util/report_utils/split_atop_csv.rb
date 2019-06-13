# frozen_string_literal: true

require "../../tests/helpers/perf_results_helper.rb"
include PerfResultsHelper # rubocop:disable Style/MixinUsage

# TODO: move to perf_results_helper.rb
# TODO: eliminate the need for this by generating separate csv files after the run

raise Exception, "you must provide a csv file" unless ARGV[0]

csv_path = ARGV[0]

def split_atop(csv_path)
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

split_atop csv_path
