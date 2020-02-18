# frozen_string_literal: true

require "optparse"

# This script is intended to be run on a GPLT test runner configured with the gplt_runner_setup plan:
# https://github.com/RandellP/gplt_runner_setup

# General namespace for metrics module
module Metrics
  # Main class for importing puppet-metrics-collector files via the json2timeseriesdb script
  #
  # @author Bill Claytor
  #
  # @attr [string] results_dir The GPLT results directory to process
  # @attr [string] prefix The prefix to use when building the server tag
  # @attr [string] json2timeseriesdb_path The path to the json2timeseriesdb.rb script
  # @attr [string] id The ID to use when building the server tag (the last segment of the results folder name)
  # @attr [string] hostname The name of the host dir currently being processed
  #
  class ImportMetricsFiles
    # rubocop:disable Style/Semicolon

    # Initialize class
    #
    # @author Bill Claytor
    #
    # @param [string] results_dir The GPLT results directory to process
    # @param [string] prefix The prefix to use when building the server tag
    # @param [string] json2timeseriesdb_path The path to the json2timeseriesdb.rb script
    #
    # @return [void]
    #
    # @example
    #   initialize(results_dir, prefix, json2timeseriesdb_path)
    #
    def initialize(results_dir, prefix, json2timeseriesdb_path)
      @results_dir = results_dir
      @prefix = prefix
      @json2timeseriesdb_path = json2timeseriesdb_path

      # if it is a perf results dir, use the timestamp segment as the ID, otherwise nil
      @id = valid_results_dir?(results_dir) ? @results_dir.split("_").last : nil
    end

    # Returns true if the specified dir is a GPLT results dir, otherwise false
    #
    # @author Bill Claytor
    #
    # @param [string] results_dir The specified results_dir to validate
    #
    # @return [Boolean] true if the specified dir is a GPLT results dir, otherwise false
    #
    # @example
    #   result = valid_results_dir?(results_dir)
    #
    def valid_results_dir?(results_dir)
      File.basename(results_dir).match?(/^PERF_(SCALE_)?\d+$/)
    end

    # The main entry point to the import_metrics_files script
    #
    # @author Bill Claytor
    #
    # @return [void]
    #
    # @example
    #   import_metrics_files
    #
    def import_metrics_files
      pmc_dir = "#{@results_dir}/puppet-metrics-collector"
      raise "puppet-metrics-collector directory not found: #{pmc_dir}" unless File.directory? pmc_dir

      output_settings

      service_dirs = Dir.glob("#{pmc_dir}/*").select { |f| File.directory? f }

      puts " service directories:"; puts service_dirs; puts

      service_dirs.each do |service_dir|
        import_metrics_files_for_service_dir(service_dir)
      end
    end

    # Outputs the specified settings
    #
    # @author Bill Claytor
    #
    # @return [void]
    #
    # @example
    #   output_settings
    #
    def output_settings
      puts "Importing puppet_metrics_collector files with the following settings:"
      puts " results_dir: #{@results_dir}"
      puts " prefix: #{@prefix}"
      puts " id: #{@id}"
      puts " json2timeseriesdb_path: #{@json2timeseriesdb_path}"
    end

    # Calls import_metrics_files_for_host_dir for each host directory
    # in the specified service directory
    #
    # @author Bill Claytor
    #
    # @param [string] service_dir The service directory to import
    #
    # @return [void]
    #
    # @example
    #   import_metrics_files
    #
    def import_metrics_files_for_service_dir(service_dir)
      puts "Checking service directory: #{service_dir}"

      host_dirs = Dir.glob("#{service_dir}/*").select { |f| File.directory? f }

      puts " host directories:"; puts host_dirs; puts

      host_dirs.each do |host_dir|
        import_metrics_files_for_host_dir(host_dir)
      end
    end

    # Calls the json2timeseriesdb.rb script for the specified host directory
    # with a server tag using the following pattern:
    # <prefix>_<id>_<hostname>
    #
    # Otherwise, if the ID is omitted:
    # <prefix>_<hostname>
    #
    # @author Bill Claytor
    #
    # @param [string] host_dir The host directory to import
    #
    # @return [void]
    #
    # @example
    #   import_metrics_files
    #
    def import_metrics_files_for_host_dir(host_dir)
      @hostname = File.basename host_dir
      pattern = "'#{host_dir}/*.json'"
      cmd = "#{@json2timeseriesdb_path} --pattern #{pattern}" \
        " --convert-to influxdb --netcat localhost --influx-db puppet_metrics --server-tag #{build_server_tag}"
      puts "Importing puppet-metrics-collector files for host: #{@hostname}"
      puts " cmd: #{cmd}"
      puts

      output = `#{cmd}`
      success = $?.success? # rubocop:disable Style/SpecialGlobalVars

      puts "Exit status was: #{$?.exitstatus}" # rubocop:disable Style/SpecialGlobalVars
      puts

      raise "ERROR - command failed with the the following output: #{output}" unless success
    end

    # Builds a server tag using the following pattern if an ID is specified:
    # <prefix>_<id>_<hostname>
    #
    # Otherwise, if the ID is omitted:
    # <prefix>_<hostname>
    #
    # @author Bill Claytor
    #
    # @return [String] The server tag
    #
    # @example:
    #   build_server_tag
    #
    def build_server_tag
      server_tag = if @id.nil?
                     "#{@prefix}_#{@hostname}"
                   else
                     "#{@prefix}_#{@id}_#{@hostname}"
                   end
      server_tag
    end

    # rubocop:enable Style/Semicolon
  end
end

if $PROGRAM_NAME == __FILE__

  DEFAULT_JSON2TIMESERIESDB_PATH = File.expand_path "~/git/puppet-metrics-collector/files/json2timeseriesdb.rb"
  DEFAULT_RESULTS_DIR = File.expand_path Dir.pwd

  DESCRIPTION = <<~DESCRIPTION
    This script imports data captured by puppet-metrics-collector.
    It checks each service subdirectory of the puppet-metrics-collector directory and calls the json2timeseriesdb.rb script once for each host subdirectory found within.
    The server tags are constructed using the following pattern:
    <prefix>_<id>_<hostname>

    For example:
    be ruby util/metrics/import_metrics.rb -r results/scale/PERF_SCALE_12345 -p slv-649

    This will result in the following server tags:
    slv-649_12345_ip-10-227-0-11j.amz-dev.puppet.net
    slv-649_12345_ip-10-227-0-22.amz-dev.puppet.net
    slv-649_12345_ip-10-227-2-173.amz-dev.puppet.net

  DESCRIPTION

  DEFAULTS = <<~DEFAULTS

    The following default values are used if the options are not specified:
    * JSON2GRAPHITE_PATH (-j, --json2timeseriesdb): #{DEFAULT_JSON2GRAPHITE_PATH}
    * DEFAULT_RESULTS_DIR (-r, --results_dir): #{DEFAULT_RESULTS_DIR}

  DEFAULTS

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
      puts DEFAULTS
      exit
    end

    opts.on("-r", "--results_dir dir_path", String, "The results directory to process") do |results_dir|
      options[:results_dir] = results_dir
    end

    opts.on("-p", "--prefix prefix", String, "The prefix to use when building the server tag") do |prefix|
      options[:prefix] = prefix
    end

    opts.on("-j", "--json2timeseriesdb file_path", String, "The json2timeseriesdb script path") do |json2timeseriesdb|
      options[:json2timeseriesdb] = json2timeseriesdb
    end
  end.parse!

  # TODO: move options validation into class when implementing SLV-685 (optionally suppress ID)
  results_dir = options[:results_dir] || DEFAULT_RESULTS_DIR
  raise "Specified directory does not exist: #{results_dir}" unless File.directory? results_dir

  raise "A prefix must be specified with the -p or --prefix option" if options[:prefix].nil?

  prefix = options[:prefix]

  json2timeseriesdb_path = options[:json2timeseriesdb] || DEFAULT_JSON2TIMESERIESDB_PATH
  unless File.exist? json2timeseriesdb_path
    raise "The json2timeseriesdb.rb script was not found: #{json2timeseriesdb_path}"
  end

  obj = Metrics::ImportMetricsFiles.new(results_dir, prefix, json2timeseriesdb_path)
  obj.import_metrics_files
end
