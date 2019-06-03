# TODO: include this functionality in every performance run
# TODO: handle file or directory as argument

require 'json'
require 'csv'

require '../../tests/helpers/perf_results_helper.rb'
include PerfResultsHelper

raise Exception, 'you must provide a results directory' unless ARGV[0]
scale_results_dir = ARGV[0]
scale_results_csv2html(scale_results_dir)
