# frozen_string_literal: true

# TODO: move to perf_results_helper.rb
# TODO: accept release names as optional arguments for A / B

require "csv"
require "../../tests/helpers/perf_results_helper.rb"
include PerfResultsHelper # rubocop:disable Style/MixinUsage

raise Exception, "you must provide two csv files to compare" unless ARGV[0] && ARGV[1]

result_a_path = ARGV[0]
result_b_path = ARGV[1]
output_path = (ARGV[2])

# TODO: refactor
def write_csv(output_path, result_a, result_b)
  row_labels = PerfResultsHelper::PERF_CSV_ROW_LABELS

  # TODO: use release names
  CSV.open(output_path.to_s, "wb") do |csv|
    csv << ["", "$RELEASE_A_NAME ($RELEASE_A_NUMBER)", "", "", "",
            "$RELEASE_B_NAME ($RELEASE_B_NUMBER)", "", "", "", ""]
    csv << ["Duration (ms)", "min", "max", "mean", "std dev", "min", "max", "mean",
            "std dev", "% (mean) diff"]

    row_labels.each_with_index do |item, index|
      res_index = index + 1
      csv << [item, result_a[res_index][1], result_a[res_index][2], result_a[res_index][3], result_a[res_index][4],
              result_b[res_index][1], result_b[res_index][2], result_b[res_index][3], result_b[res_index][4],
              percent_diff_string(result_a[res_index][3], result_b[res_index][3])]
    end
  end
end

def compare_results(result_a_path, result_b_path, output_path)
  result_a_name = File.basename(result_a_path, ".*")
  result_b_name = File.basename(result_b_path, ".*")

  output_path ||= "./#{result_a_name}_vs_#{result_b_name}.csv"

  puts "Comparing #{result_a_name} and #{result_b_name}"
  puts "Creating #{output_path}"

  result_a = CSV.read(result_a_path)
  result_b = CSV.read(result_b_path)

  write_csv(output_path, result_a, result_b)
  csv2html(output_path)
end

compare_results(result_a_path, result_b_path, output_path)
