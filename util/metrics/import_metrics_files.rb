# frozen_string_literal: true

require "optparse"

# TODO: more...
DESCRIPTION = <<~DESCRIPTION
  This script imports metrics collector data for the Standard and Large reference architectures.
  It checks each service subdirectory of the puppet-metrics-collector directory and calls the json2graphite.rb script once for each host subdirectory found within.
  The server tags are constructed using the following pattern:
  prefix_id_hostname

  For example:
  be ruby util/metrics/import_metrics.rb -r results/scale/PERF_SCALE_12345 -p slv-649

  This will result in the following server tags:
  slv-649_12345_127.0.0.1
  slv-649_12345_ip-10-227-0-22.amz-dev.puppet.net
  slv-649_12345_ip-10-227-2-173.amz-dev.puppet.net

DESCRIPTION

options = {}

# Note: looks like 'Store options to a Hash' doesn't work in Ruby 2.3.0.
# https://ruby-doc.org/stdlib-2.6.3/libdoc/optparse/rdoc/OptionParser.html
#  `end.parse!(into: options)`
# TODO: update to use '(into: options)' after Ruby update

OptionParser.new do |opts|
  opts.banner = "Usage: import_metrics_files.rb [options]"

  opts.on("-h", "--help", "Display the help text") do
    puts DESCRIPTION
    puts opts
    exit
  end

  opts.on("-r", "--results_dir RESULTS_DIR", String, "The results directory to process") do |results_dir|
    options[:results_dir] = results_dir
  end

  opts.on("-p", "--prefix PREFIX", String, "The prefix to use when building the server tag") do |prefix|
    options[:prefix] = prefix
  end
end.parse!

# error if options are not specified
raise "A results directory must be specified with the -r or --results_dir option" if options[:results_dir].nil?
raise "A prefix must be specified with the -p or --prefix option" if options[:prefix].nil?

RESULTS_DIR = options[:results_dir]
PREFIX = options[:prefix]
ID = RESULTS_DIR.split("_").last

# TODO: make this optional?
JSON2GRAPHITE_PATH = "~/git/puppet-metrics-viewer/json2graphite.rb"

# This is the main entry point to the import_metrics_files script
#
# @author Bill Claytor
#
# @example
#   import_metrics_files
#
def import_metrics_files
  puts "Importing puppet_metrics_collector files:"
  puts " results_dir: #{RESULTS_DIR}"
  puts " prefix: #{PREFIX}"
  puts " id: #{ID}"

  pmc_dir = "#{RESULTS_DIR}/puppet-metrics-collector"

  raise "Specified results directory does not exist: #{RESULTS_DIR}" unless File.directory? RESULTS_DIR
  raise "Directory not found: #{pmc_dir}" unless File.directory? pmc_dir

  service_dirs = Dir.glob("#{RESULTS_DIR}/puppet-metrics-collector/*").select { |f| File.directory? f }

  puts " service directories:"
  puts service_dirs
  puts

  # each service directory
  service_dirs.each do |service_dir|
    puts "Checking directory: #{service_dir}"

    # each host directory
    host_dirs = Dir.glob("#{service_dir}/*").select { |f| File.directory? f }

    puts " host directories: "
    puts host_dirs
    puts

    host_dirs.each do |host_dir|
      import_metrics_files_for_host_dir host_dir
    end
  end
end

# Calls the json2graphite.rb script for the specified host directory
# with a server tag using the following pattern: prefix_id_hostname
#
#
# @author Bill Claytor
#
# @example
#   import_metrics_files
#
def import_metrics_files_for_host_dir(host_dir)
  hostname = File.basename host_dir
  server_tag = "#{PREFIX}_#{ID}_#{hostname}"
  pattern = "'#{host_dir}/*.json'"
  cmd = "ruby #{JSON2GRAPHITE_PATH} --pattern #{pattern}" \
        " --convert-to influxdb --netcat localhost --influx-db puppet_metrics --server-tag #{server_tag}"
  puts "Importing puppet-metrics-collector files for host: #{hostname}"
  puts " cmd: #{cmd}"
  puts

  `#{cmd}`
end

import_metrics_files if $PROGRAM_NAME == __FILE__
