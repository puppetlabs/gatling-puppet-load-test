# frozen_string_literal: true

require "thor"
require "./tests/helpers/perf_run_helper"

require "pry"

module GPLT
  class Error < StandardError; end

  # Class to define CLI subcommands
  class CLI < Thor
    extend PerfRunHelper

    default_test_type = "apples to apples"

    option :test_type, default: default_test_type
    option :baseline, required: true
    option :results_dir, required: true

    desc "validate2baseline",
         "validate perf results against baseline data"

    long_desc <<-LONGDESC
      `validate2baseline` validates performance results data against baseline data.

      You must specify a --baseline for the baseline data and a --results_dir
      containing the performance results to compare for validation.

      The --test_type is optional and defaults to "#{default_test_type}"

      A passing state will echo "PASS" to STDOUT and exit with 0.
      A failing state will echo "FAIL" to STDOUT and exit with 1.
    LONGDESC

    def validate2baseline
      if CLI.validate_results_to_baseline(options[:results_dir], options[:baseline], options[:test_type])
        puts "PASS"
        exit 0
      else
        puts "FAIL"
        exit 1
      end
    end
  end
end
