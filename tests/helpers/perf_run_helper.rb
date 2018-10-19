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

  def perf_teardown
    perf_result
    if push_to_bigquery?
      push_to_bigquery
      logger.info("Pushing perf metrics to BigQuery.")
    else
      logger.info("Not pushing perf metrics to BigQuery as PUSH_TO_BIGQUERY is false.")
    end
  end

  def assertion_exceptions
    @assertion_exceptions ||= []
  end

  def assert_later(expression_result, message)
    begin
      assert(expression_result, message)
    rescue Minitest::Assertion => ex
      assertion_exceptions.push(ex)
    end
  end

  def assert_all
    assertion_exceptions.each { |ex|
      logger.error("#{ex.message}\n#{ex.backtrace}")
    }
    flunk('One or more assertions failed') unless assertion_exceptions.size == 0
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
    dir = "#{@archive_root}/#{metric.hostname}/root/gatling-puppet-load-test/simulation-runner/results/#{@dir_name}"
    file = "/js/global_stats.json"
    logger.info("Getting mean response time from #{dir}#{file}")
    raise System.StandardError 'The file does not exist' unless File.exist?("#{dir}#{file}")
    json_from_file = File.read("#{dir}#{file}")
    logger.info("global_stats.json: #{json_from_file}")
    json = JSON.parse(json_from_file)
    json.fetch('meanResponseTime').fetch('total')
  end

  def mean_response_time
    @mean_response_time ||= get_mean_response_time
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
      @max_response_time_agent = assertions.find {|result| result['target'] === '99th percentile of response time' }.fetch('actual_value')[0].to_i
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
               "avg_disk_write" => @perf_result[0].avg_disk_write,
               "avg_response_time" => mean_response_time
           }]

    process_hash = get_process_hash @perf_result[0].processes
    row[0].merge! process_hash

    logger.info "row is: #{row.to_s}"

    result = atop_table.insert row
    if result.success?
      logger.info("inserted row successfully into BigQuery: #{row}")
    else
      logger.error(result.insert_errors)
    end
  end

  def get_process_hash perf_result_processes
    process_hash = {}
    perf_result_processes.keys.each do |key|
      # All of the puppet processes we care about are jars
      process_match = perf_result_processes[key][:cmd].match(/.*\/([a-z,\-]*)\.jar/)
      unless process_match.nil?
        process_name = process_match[1]
        process_hash["process_#{process_name.gsub('-', '_')}_avg_cpu"] = perf_result_processes[key][:avg_cpu]
        process_hash["process_#{process_name.gsub('-', '_')}_avg_mem"] = perf_result_processes[key][:avg_mem]
      end
    end
    process_hash
  end

  def get_baseline_result
    unless BASELINE_PE_VER.nil?
      #compare results created in this run with latest baseline run
      sql = 'SELECT avg_cpu, avg_mem, avg_disk_write, avg_response_time, ' \
            'process_puppetdb_avg_cpu, process_puppetdb_avg_mem, ' \
            'process_console_services_release_avg_cpu, process_console_services_release_avg_mem, ' \
            'process_orchestration_services_release_avg_cpu, process_orchestration_services_release_avg_mem, ' \
            'process_puppet_server_release_avg_cpu, process_puppet_server_release_avg_mem ' \
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
      data[0]
    else
      logger.warn('Not comparing results with baseline as BASELINE_PE_VER was not set.')
      return nil
    end
  end

  def baseline_assert atop_result, gatling_result
    process_results = get_process_hash(atop_result.processes)

    # Handle 3 different things: avg_response_time which comes from gatling result,
    # global atop results and per process atop results
    baseline = get_baseline_result
    unless baseline.nil?
      baseline.each do |key, value|
        if key.to_s == "avg_response_time"
          assert_value = gatling_result.avg_response_time.to_f
        elsif key.to_s.start_with? "process"
          assert_value = process_results[key.to_s].to_f
        else
          assert_value = atop_result.send(key).to_f
        end

        if value.is_a? Integer
          # If the baseline value is 10 or lower (usually CPU) then we need to allow more than 10% variance
          # since it is only whole numbers. If it is 10 or less, we should allow for +1 or -1
          if value <= 10
            assert_later(assert_value.between?(value -1, value + 1), "The value of #{key} '#{assert_value}' " +
                "was not within 10% of the baseline '#{value}'")
          else
            assert_later((assert_value - value) / value * 100 <= 10, "The value of #{key} '#{assert_value}' " +
                "was not within 10% of the baseline '#{value}'")
          end
        end
      end
    end
  end

end



Beaker::TestCase.send(:include, PerfRunHelper)
