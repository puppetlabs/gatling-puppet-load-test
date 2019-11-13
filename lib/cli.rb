# frozen_string_literal: true

require "./tests/helpers/perf_run_helper"

# Add pry support when available
begin
  require "pry"
rescue LoadError # rubocop: disable Lint/HandleExceptions
  # do nothing
end

module GPLT
  # Class for holding command line methods
  class CLI
    extend PerfRunHelper
    def validate2baseline(options)
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
