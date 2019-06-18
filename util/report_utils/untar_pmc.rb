# frozen_string_literal: true

require "json"
require "csv"

PUPPET_METRICS_COLLECTOR_SERVICES = %w[orchestrator puppetdb puppetserver].freeze

raise Exception, "you must provide a result folder" unless ARGV[0]

puppet_metrics_dir = ARGV[0]

# TODO: move to perf_results_helper?
def extract_puppet_metrics_collector_tarballs(puppet_metrics_dir)
  puts "Extracting all tar.gz files in #{puppet_metrics_dir}"
  puts

  PUPPET_METRICS_COLLECTOR_SERVICES.each do |service|
    service_dir = "#{puppet_metrics_dir}/#{service}"

    puts "Extracting files for service: #{service}"

    # change to the service directory
    Dir.chdir service_dir

    # extract each tar file to the service directory
    Dir.glob("*.tar.gz").each do |file|
      puts "Extracting #{file}"

      # extract
      command = "tar xfz #{file} -C #{service_dir}"
      `#{command}`
    end

    puts
  end
end

extract_puppet_metrics_collector_tarballs(puppet_metrics_dir)
