# frozen_string_literal: true

# TODO: move to perf_results_helper.rb
# TODO: accept release names as optional arguments for A / B

require "csv"
require "../../tests/helpers/perf_results_helper.rb"
include PerfResultsHelper # rubocop:disable Style/MixinUsage

raise Exception, "you must provide two csv files to compare" unless ARGV[1] && ARGV[2]

result_a_path = ARGV[0]
result_b_path = ARGV[1]

# TODO: refactor
# rubocop: disable Metrics/AbcSize
def write_csv(output_path, result_a, result_b)
  # TODO: use release names
  CSV.open(output_path.to_s, "wb") do |csv|
    csv << ["", "$RELEASE_A_NAME ($RELEASE_A_NUMBER)", "", "",
            "$RELEASE_B_NAME ($RELEASE_B_NUMBER)", "", ""]
    csv << ["Duration", "max ms", "mean ms", "std dev", "max ms", "mean ms",
            "std dev", "% (mean) diff"]

    csv << ["Total", result_a[1][1], result_a[1][2], result_a[1][3],
            result_b[1][1], result_b[1][2], result_b[1][3],
            diff_perf_results(result_a[1][2], result_b[1][2])]
    csv << ["catalog", result_a[2][1], result_a[2][2], result_a[2][3],
            result_b[2][1], result_b[2][2], result_b[2][3],
            diff_perf_results(result_a[2][2], result_b[2][2])]
    csv << ["filemeta plugins", result_a[3][1], result_a[3][2], result_a[3][3],
            result_b[3][1], result_b[3][2], result_b[3][3],
            diff_perf_results(result_a[3][2], result_b[3][2])]
    csv << ["filemeta pluginfacts", result_a[4][1], result_a[4][2],
            result_a[4][3], result_b[4][1], result_b[4][2], result_b[4][3],
            diff_perf_results(result_a[4][2], result_b[4][2])]
    csv << ["locales", result_a[5][1], result_a[5][2], result_a[5][3],
            result_b[5][1], result_b[5][2], result_b[5][3],
            diff_perf_results(result_a[5][2], result_b[5][2])]
    csv << ["node", result_a[1][1], result_a[6][2], result_a[6][3],
            result_b[6][1], result_b[6][2], result_b[6][3],
            diff_perf_results(result_a[6][2], result_b[6][2])]
    csv << ["report", result_a[7][1], result_a[7][2], result_a[7][3],
            result_b[7][1], result_b[7][2], result_b[7][3],
            diff_perf_results(result_a[7][2], result_b[7][2])]
  end
end
# rubocop: enable Metrics/AbcSize

def compare_results(result_a_path, result_b_path)
  result_a_name = File.basename(result_a_path, ".*")
  result_b_name = File.basename(result_b_path, ".*")

  # TODO: refactor
  output_path = ARGV[2] || "./#{result_a_name}_vs_#{result_b_name}.csv"

  puts "Comparing #{result_a_name} and #{result_b_name}"
  puts "Creating #{output_path}"

  result_a = CSV.read(result_a_path)
  result_b = CSV.read(result_b_path)

  write_csv(output_path, result_a, result_b)
  csv2html(output_path)
end

compare_results(result_a_path, result_b_path)
