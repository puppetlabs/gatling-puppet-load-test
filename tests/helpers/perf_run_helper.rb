require 'beaker'
require 'beaker-benchmark'
require "google/cloud/bigquery"

module PerfRunHelper

  BEAKER_PE_VER = ENV['BEAKER_PE_VER']
  BASELINE_PE_VER = ENV['BASELINE_PE_VER']


  def perf_setup(gatling_scenario, simulation_id, gatlingassertions)
    @atop_session_timestamp = start_monitoring(master, gatling_scenario, true, 30)
    execute_gatling_scenario(gatling_scenario, simulation_id, gatlingassertions)
  end

  def perf_result
    @perf_result ||= get_perf_result
  end

  def baseline_result
    @baseline_result ||= get_baseline_result
  end

  def perf_teardown
    perf_result
    if push_to_bigquery?
      push_to_bigquery
      logger.info("Pushing perf metrics to BigQuery.")
    else
      logger.info("Not pushing perf metrics to BigQuery as PUSH_TO_BIGQUERY is false.")
    end
  end


  private

  def execute_gatling_scenario(gatling_scenario, simulation_id, gatlingassertions)
    step "Execute gatling scenario" do

      # Should gatling run reports only?
      if ENV['PUPPET_GATLING_REPORTS_ONLY'] == "true"
        reports_only = "true"
        reports_target = ENV['PUPPET_GATLING_REPORTS_TARGET']
      else
        reports_only = "false"
        reports_target = ""
      end

      on(metric, "cd /root/gatling-puppet-load-test/simulation-runner/ && " +
          "PUPPET_GATLING_MASTER_BASE_URL=https://#{master.hostname}:8140 " +
          "PUPPET_GATLING_SIMULATION_CONFIG=config/scenarios/#{gatling_scenario} " +
          gatlingassertions +
          "PUPPET_GATLING_REPORTS_ONLY=#{reports_only} " +
          "PUPPET_GATLING_REPORTS_TARGET=/root/gatling-puppet-load-test/simulation-runner/results/#{reports_target} " +
          "PUPPET_GATLING_SIMULATION_ID=#{simulation_id} sbt run",
         {:accept_all_exit_codes => true}) do |result|
        if result.exit_code != 0 then
          fail_test "Gatling execution failed with: #{result.formatted_output(20)}"
        end
        #parse output to get name of log dir (in format PerfTestLarge-*time_stamp* )
        out = result.formatted_output(20)
        split = out.split("\n")
        index = split.index{|s| s.include?("Please open the following file")}
        dir_entry = split[index]
        path_array = dir_entry.split("/")
        result_index = path_array.index{|s| s.include?(simulation_id)}
        @dir_name = path_array[result_index]
      end
    end
  end


  def get_mean_response_time
    dir = "#{@archive_root}/#{metric}/root/gatling-puppet-load-test/simulation-runner/results/#{@dir_name}"
    json_from_file = File.read("#{dir}/js/global_stats.json")
    json = JSON.parse(json_from_file)
    json.fetch('meanResponseTime').fetch('total')
  end

  def mean_response_time
    @mean_response_time || get_mean_response_time
  end

  def gatling_assertions
    @gatling_assertions ||= get_gatling_assertions
  end

  def get_gatling_assertions
    dir = "#{@archive_root}/#{metric}/root/gatling-puppet-load-test/simulation-runner/results/#{@dir_name}"
    json_from_file = File.read("#{dir}/js/assertions.json")
    json = JSON.parse(json_from_file)
    gatling_assertions = []
    json['assertions'].each do |assertion|
      gatling_assertions << {'expected_values' => assertion['expectedValues'], 'message' => assertion['message'] ,
                             'actual_value' => assertion['actualValue'], 'target' => assertion['target']}
    end
    gatling_assertions
  end

  def copy_archive_files
    now = Time.now.getutc.to_i
    # truncate the job name so it only has the name-y part and no parameters
    if ENV['JOB_NAME']
      job_name = ENV['JOB_NAME']
                     .sub(/[A-Z0-9_]+=.*$/, '')
                     .gsub(/[\/,.]/, '_')[0..200]
    else
      job_name = 'unknown_or_dev_job'
    end

    archive_name = "#{job_name}__#{ENV['BUILD_ID']}__#{now}__perf-files.tgz"
    @archive_root = "PERF_#{now}"

    # Archive the gatling result htmls from the metrics box and the atop results from the master (which are already copied locally)
    if (Dir.exist?("tmp/atop/#{@atop_session_timestamp}/#{master.hostname}"))
      FileUtils.mkdir_p "#{@archive_root}/#{master.hostname}"
      FileUtils.cp_r "tmp/atop/#{@atop_session_timestamp}/#{master.hostname}/", "#{@archive_root}"
      if !@dir_name.nil?
        archive_file_from(metric, "/root/gatling-puppet-load-test/simulation-runner/results/#{@dir_name}", {}, @archive_root, archive_name)
      end
    end
  end

  def get_perf_result
    perf = stop_monitoring(master, '/opt/puppetlabs')
    if perf
      perf.log_summary
      # Write summary results to log so it can be archived
      perf.log_csv
      copy_archive_files
    end
    return perf, GatlingResult.new(gatling_assertions, mean_response_time)
  end

  class GatlingResult
    attr_accessor :avg_response_time, :successful_requests, :max_response_time_agent, :request_count
    def initialize(assertions, mean_response)
      @avg_response_time = mean_response
      @successful_requests = assertions.find {|result| result['target'] === 'percentage of successful requests' }.fetch('actual_value')[0].to_i
      @max_response_time_agent = assertions.find {|result| result['target'] === 'max of response time' }.fetch('actual_value')[0].to_i
      @request_count = assertions.find {|result| result['target'] === 'count of all requests' }.fetch('actual_value')[0].to_i
    end
  end

  def push_to_bigquery?
    ENV['PUSH_TO_BIGQUERY'] ||= 'false'
    eval(ENV['PUSH_TO_BIGQUERY'])
  end

  def push_to_bigquery
    bigquery = Google::Cloud::Bigquery.new project: "perf-metrics"
    dataset = bigquery.dataset "perf_metrics"
    atop_table = dataset.table "atop_metrics"

    row = [{
               "pe_build_number" => BEAKER_PE_VER, #"2018.1.1-rc0-11-g8fbde83",
               "test_scenario" => current_test_name(),
               "time_stamp" => Time.now,
               "avg_cpu" => @perf_result[0].avg_cpu,
               "avg_mem" => @perf_result[0].avg_mem,
               "avg_dsk_write" => @perf_result[0].avg_disk_write,
               "avg_response_time" => get_mean_response_time
           }]

    result = atop_table.insert row
    if result.success?
      logger.info("inserted row successfully into BigQuery: #{row}")
    else
      logger.error(result.insert_errors)
    end
  end

  def get_baseline_result
    if BASELINE_PE_VER != nil
      #compare results created in this run with latest baseline run
      sql = 'SELECT avg_cpu, avg_mem, avg_dsk_write, avg_response_time ' \
            'FROM `perf-metrics.perf_metrics.atop_metrics` ' \
            'WHERE time_stamp = (' \
          'SELECT MAX(time_stamp) ' \
        'FROM `perf-metrics.perf_metrics.atop_metrics` ' \
        "WHERE pe_build_number = '#{BASELINE_PE_VER}' AND test_scenario = '#{current_test_name()}' " \
           'GROUP BY pe_build_number, test_scenario)'

      bigquery = Google::Cloud::Bigquery.new project: "perf-metrics"
      data = bigquery.query sql
      if !data.empty?
        logger.info("Baseline result returned from BigQuery: #{data}")
      else
        logger.error("Cannot find result that matches query: #{sql}")
      end
      BaselineResult.new(data)
    else
      skip_test('Not comparing results with baseline as BASELINE_PE_VER was not set.')
    end
  end

  class BaselineResult
    attr_accessor :baseline_cpu, :baseline_memory, :baseline_dsk_write, :baseline_avg_resp_time
    def initialize(data)
      @baseline_cpu = data[0].fetch(:avg_cpu)
      @baseline_memory = data[0].fetch(:avg_mem)
      @baseline_dsk_write = data[0].fetch(:avg_dsk_write)
      @baseline_avg_resp_time = data[0].fetch(:avg_response_time)
    end
  end

end



Beaker::TestCase.send(:include, PerfRunHelper)