require 'beaker'
require 'beaker-benchmark'
require "google/cloud/bigquery"

module PerfRunHelper

  BEAKER_PE_VER = ENV['BEAKER_PE_VER']
  BASELINE_PE_VER = ENV['BASELINE_PE_VER']
  SCALE_ITERATIONS = 10
  SCALE_INCREMENT = 100
  PUPPET_METRICS_COLLECTOR_SERVICES = %w[orchestrator puppetdb puppetserver]

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

  # Iteratively run perf_setup while automatically scaling the number of agents
  #
  # @author Bill Claytor
  #
  # @param [String] gatling_scenario The gatling scenario json file to use
  # @param [String] simulation_id The simulation ID to include in the results
  # @param [String] gatlingassertions The assertions that will be specified for each iteration of the scenario
  #
  # @return [void]
  #
  # @example:
  #   assertions = "SUCCESSFUL_REQUESTS=100 " + "MAX_RESPONSE_TIME_AGENT=20000 "  + "TOTAL_REQUEST_COUNT=28800 "
  #   scenario = "Scale.json"
  #   simulation_id = "PerfAutoScale"
  #   scale_setup(gatling_scenario, simulation_id, gatlingassertions)
  #
  def scale_setup(gatling_scenario, simulation_id, gatlingassertions)
    @scale_timestamp = Time.now.getutc.to_i
    @scale_scenarios = []

    env_iterations = ENV['PUPPET_GATLING_SCALE_ITERATIONS']
    env_increment = ENV['PUPPET_GATLING_SCALE_INCREMENT']
    @scale_iterations = env_iterations ? Integer(env_iterations) : SCALE_ITERATIONS
    @scale_increment = env_increment ? Integer(env_increment) : SCALE_INCREMENT

    # generate scenario files and copy to metrics
    generate_scale_scenarios(gatling_scenario)

    # create scale results dir
    scale_results_parent_dir = "results/scale/PERF_SCALE_#{@scale_timestamp}"
    create_parent_scale_results_folder(scale_results_parent_dir)

    puts "Executing scale tests:"
    puts "base number of agents = #{@scale_base_instances}"
    puts "number of iterations = #{@scale_iterations}"
    puts "number to increment = #{@scale_increment}"
    puts

    # execute each scenario
    ct = 0
    @scale_scenarios.each do |scenario_hash|

      scenario = scenario_hash[:name]
      # scale_scenario_instances = scenario_hash[:instances]

      ct = ct + 1

      # run the scenario
      puts "Iteration #{ct} of #{@scale_scenarios.length}"
      puts

      # purge the metrics collector output and restart the service
      purge_puppet_metrics_collector
      restart_puppetserver

      # run the scenario
      puts "Running scenario #{ct} of #{@scale_scenarios.length} : #{scenario}"
      puts

      perf_setup(scenario, simulation_id, gatlingassertions)

      # get results, copy from metrics, check for KOs, fail if ko != 0, assertions
      success = handle_scale_results(scenario_hash)
      break unless success
    end

  end

  # Create a timestamped folder for the entire scale run
  #
  # @author Bill Claytor
  #
  # @return [void]
  #
  # @example
  #   create_parent_scale_results_folder
  #
  def create_parent_scale_results_folder(scale_results_parent_dir)
    FileUtils.mkdir_p scale_results_parent_dir

    # link current result to latest
    s = File.expand_path(scale_results_parent_dir)
    d = File.expand_path("results/scale/latest")
    puts "Linking s:#{s} to d:#{d}"

    # TODO: removal and force options seemed necessary to avoid sub-dir link
    FileUtils.rm "results/scale/latest", :force => true
    FileUtils.ln_s s, d, :force => true

    # create log dir
    FileUtils.mkdir_p "#{scale_results_parent_dir}/log"

    # create results csv
    create_scale_results_csv_file(scale_results_parent_dir)

    # create scale results env file
    create_scale_results_env_file(scale_results_parent_dir)

    # create current pe tune file
    create_pe_tune_file(scale_results_parent_dir)
  end

  # Create the CSV file for the scale run and add the headings row
  #
  # @author Bill Claytor
  #
  # @param [String] perf_scale_dir The results directory for the scale run
  #
  # @return [void]
  #
  # @example
  #   create_scale_results_csv_file(perf_scale_dir)
  #
  def create_scale_results_csv_file(scale_results_parent_dir)
    CSV.open("#{scale_results_parent_dir}/PERF_SCALE_#{@scale_timestamp}.csv", "wb") do |csv|
      headings = ["agents",
                  "ok",
                  "ko",
                  "combined mean",
                  "catalog mean",
                  "filemeta plugins mean",
                  "filemeta pluginfacts mean",
                  "locales mean",
                  "node mean",
                  "report mean",
                  "average CPU %",
                  "average memory"]

      csv << headings
    end
  end

  # Create the beaker env file for the scale run
  #
  # @author Bill Claytor
  #
  # @param [String] perf_scale_dir The results directory for the scale run
  #
  # @return [void]
  #
  # @example
  #   create_scale_results_env_file(perf_scale_dir)
  #
  def create_scale_results_env_file(scale_results_parent_dir)
    open("#{scale_results_parent_dir}/beaker_environment.txt", 'w') { |f|
      f << "BEAKER_INSTALL_TYPE: #{ENV["BEAKER_INSTALL_TYPE"]}\n"
      f << "BEAKER_PE_DIR: #{ENV["BEAKER_PE_DIR"]}\n"
      f << "BEAKER_PE_VER: #{ENV["BEAKER_PE_VER"]}\n"
      f << "BEAKER_TESTS: #{ENV["BEAKER_TESTS"]}\n"
      f << "PUPPET_SCALE_CLASS: #{ENV["PUPPET_SCALE_CLASS"]}\n"
      f << "PUPPET_GATLING_SCALE_SCENARIO: #{ENV["PUPPET_GATLING_SCALE_SCENARIO"]}\n"
      f << "PUPPET_GATLING_SCALE_BASE_INSTANCES: #{ENV["PUPPET_GATLING_SCALE_BASE_INSTANCES"]}\n"
      f << "PUPPET_GATLING_SCALE_ITERATIONS: #{ENV["PUPPET_GATLING_SCALE_ITERATIONS"]}\n"
      f << "PUPPET_GATLING_SCALE_INCREMENT: #{ENV["PUPPET_GATLING_SCALE_INCREMENT"]}\n"
      f << "PUPPET_GATLING_SCALE_TUNE: #{ENV["PUPPET_GATLING_SCALE_TUNE"]}\n"
      f << "PUPPET_GATLING_SCALE_TUNE_FORCE: #{ENV["PUPPET_GATLING_SCALE_TUNE_FORCE"]}\n"
      f << "ABS_AWS_METRICS_SIZE: #{ENV["ABS_AWS_METRICS_SIZE"]}\n"
      f << "ABS_AWS_MOM_SIZE: #{ENV["ABS_AWS_MOM_SIZE"]}\n"
      f << "AWS_VOLUME_SIZE: #{ENV["AWS_VOLUME_SIZE"]}\n"
    }
  end

  # Create the pe_tune_current file for the scale run
  #
  # @author Bill Claytor
  #
  # @param [String] perf_scale_dir The results directory for the scale run
  #
  # @return [void]
  #
  # @example
  #   create_pe_tune_file(perf_scale_dir)
  #
  def create_pe_tune_file(scale_results_parent_dir)
    output = puppet_infrastructure_tune_current
    File.write("#{scale_results_parent_dir}/pe_tune_current.txt", output)
  end

  # Get the current pe tune
  #
  # @author Bill Claytor
  #
  # @return [void]
  #
  # @example
  #   output = puppet_infrastructure_tune_current
  #
  def puppet_infrastructure_tune_current
    puts "Checking current PE tune..."
    puts

    output = on(master, "puppet infrastructure tune --current").output

    puts output
    puts

    return output
  end

  # Restart the pe-puppetserver service
  #
  # @author Bill Claytor
  #
  # @return [void]
  #
  # @example
  #   restart_puppetserver
  #
  def restart_puppetserver
    if ENV["PUPPET_GATLING_SCALE_RESTART_PUPPETSERVER"].eql?("false")
      puts "PUPPET_GATLING_SCALE_RESTART_PUPPETSERVER is set to false..."
      puts "Skipping pe-puppetserver service restart..."
      puts
    else
      puts "Restarting pe-puppetserver service..."
      puts

      on master, "service pe-puppetserver restart"

      puts "Sleeping..."
      puts

      sleep 60
    end

  end

  # Purge the puppet-metrics-collector log files for each service
  #
  # @author Bill Claytor
  #
  # @return [void]
  #
  # @example
  #   purge_puppet_metrics_collector
  #
  def purge_puppet_metrics_collector
    puts "Purging puppet_metrics_collector..."
    puts

    PUPPET_METRICS_COLLECTOR_SERVICES.each do |service|
      dir = "/opt/puppetlabs/puppet-metrics-collector/#{service}"
      command = "find #{dir} -type f -delete"
      on master, command
    end

  end

  # Copy the puppet-metrics-collector log files for each service
  #
  # @author Bill Claytor
  #
  # @param [String] perf_scale_dir The results directory for the scale run
  #
  # @return [void]
  #
  # @example
  #   copy_puppet_metrics_collector(perf_scale_dir)
  #
  def copy_puppet_metrics_collector(scale_results_parent_dir)
    puts "Copying puppet_metrics_collector..."
    puts

    PUPPET_METRICS_COLLECTOR_SERVICES.each do |service|
      source_dir = "/opt/puppetlabs/puppet-metrics-collector/#{service}"
      dest_parent = "#{scale_results_parent_dir}/puppet-metrics-collector"

      FileUtils.mkdir_p dest_parent
      scp_from(master, "#{source_dir}", "#{dest_parent}")
    end
  end

  # Generate a name for the scenario that includes the iteration and number of instances
  #
  # @author Bill Claytor
  #
  # @param [String] scale_basename The scale scenario name + the scale timestamp ("Scale_1547599624")
  # @param [Integer] iteration The current scale iteration
  # @param [Integer] instances The number of instances for the current scale iteration
  #
  # @return [String] The generated scenario filename
  #
  # @example
  #   scale_scenario_name = generate_scale_scenario_name("Scale_1547599624", 5, 3500)
  #   scale_scenario_name == "Scale_1547599624_05_3500.json"
  #
  def generate_scale_scenario_name(scale_basename, iteration, instances)
    # format the scenario number so they appear listed in order
    scenario_num_len = @scale_iterations.to_s.length

    # format the scenario number so they appear listed in order
    iteration_num_len = iteration.to_s.length
    prefix_len = scenario_num_len - iteration_num_len

    prefix = ""
    (1..prefix_len).each do
      prefix = prefix + "0"
    end

    scenario_name = "#{scale_basename}_#{prefix}#{iteration}_#{instances}.json"
    return scenario_name
  end

  # Generate the scenario files with the corresponding values for each iteration
  #
  # @author Bill Claytor
  #
  # @param [String] gatling_scenario The gatling scenario json file to use
  #
  # @return [void]
  #
  # @example
  #   generate_scale_scenarios(gatling_scenario)
  #
  def generate_scale_scenarios(gatling_scenario)

    scenarios_dir = "simulation-runner/config/scenarios"

    # generate auto-scaled scenario files
    basename = File.basename("#{scenarios_dir}/#{gatling_scenario}", ".json")
    scale_basename = "#{basename}_#{@scale_timestamp}"
    file = File.read("#{scenarios_dir}/#{gatling_scenario}")
    json = JSON.parse(file)

    # allow the base instances to be set via environment variable
    env_base_instances = ENV['PUPPET_GATLING_SCALE_BASE_INSTANCES']
    json_base_instances = json["nodes"][0]["num_instances"]

    # TODO: refactor
    if !env_base_instances.nil?
      puts "Using environment specified base instances: #{env_base_instances}"
      @scale_base_instances = Integer(env_base_instances)

      # update json
      desc = "'role::by_size_small' role from perf control repo, #{@scale_base_instances} agents, 1 iteration"
      json["run_description"] = desc
      json["nodes"][0]["num_instances"] = @scale_base_instances
    else
      puts "Using JSON specified base instances: #{json_base_instances}"
      @scale_base_instances = json_base_instances
    end

    instances = @scale_base_instances

    for iteration in 1..@scale_iterations do

      # create scenario with the current data (first scenario is the original)
      scenario_name = generate_scale_scenario_name(scale_basename, iteration, instances)
      File.write("#{scenarios_dir}/#{scenario_name}", json.to_json)

      # add scenario hash to the array
      @scale_scenarios << {:name => scenario_name, :instances => instances}

      # update the data for the next iteration
      instances = instances + @scale_increment
      desc = "'role::by_size_small' role from perf control repo, #{instances} agents, 1 iteration"
      json["run_description"] = desc
      json["nodes"][0]["num_instances"] = instances

    end

    # upload scenarios to metrics
    scp_to(metric, "#{scenarios_dir}", "gatling-puppet-load-test/simulation-runner/config")
  end

  # Handle gathering and evaluating the scale results for the current iteration
  #
  # @author Bill Claytor
  #
  # @param [Hash] scenario_hash The scenario hash for the current iteration
  #
  # @return [true,false] Based on the success of the scale iteration
  #
  # @example
  #   handle_scale_results(scenario_hash)
  #
  def handle_scale_results(scenario_hash)
    scenario = scenario_hash[:name]

    puts "Getting results for scenario: #{scenario}"
    puts

    # stop monitoring and get results
    get_perf_result

    # copy results from metrics node
    copy_scale_results(scenario)

    # check results for KOs
    success = check_scale_results(scenario_hash)

    return success
  end

  # Copy the perf results and log files (including puppet-metrics-collector) to the scale results folder
  #
  # @author Bill Claytor
  #
  # @param [String] scenario The scenario for the current scale iteration
  #
  # @return [void]
  #
  # @example
  #   copy_scale_results(scenario)
  #
  def copy_scale_results(scenario)
    puts "Getting results for scenario: #{scenario}"
    puts

    # create scale scenario result folder
    scale_results_parent_dir = "results/scale/PERF_SCALE_#{@scale_timestamp}"
    scale_result_dir = "#{scale_results_parent_dir}/#{scenario.gsub(".json", "")}"
    FileUtils.mkdir_p scale_result_dir

    # copy entire results to scale results dir (TODO: remove this?)
    # perf_result_dir = File.basename(@archive_root)
    # FileUtils.copy_entry @archive_root, "#{scale_result_dir}/#{perf_result_dir}"

    # copy metric
    remote_result_dir = "root/gatling-puppet-load-test/simulation-runner/results"
    metric_results = "#{@archive_root}/#{metric.hostname}/#{remote_result_dir}/#{@dir_name}"
    FileUtils.copy_entry metric_results, "#{scale_result_dir}/metric"

    # copy master
    master_results = "#{@archive_root}/#{master.hostname}"
    log_filename = "atop_log_#{scenario.downcase.gsub(".json", "_json")}"

    # copy only the logs for this iteration (the dir contains logs from all previous iterations)
    # FileUtils.copy_entry master_results, "#{scale_result_dir}/master"
    FileUtils.mkdir_p "#{scale_result_dir}/master"
    FileUtils.copy_file "#{master_results}/#{log_filename}.log", "#{scale_result_dir}/master/#{log_filename}.log"
    FileUtils.copy_file "#{master_results}/#{log_filename}.csv", "#{scale_result_dir}/master/#{log_filename}.csv"

    # copy stats
    global_stats_path = "#{scale_result_dir}/metric/js/global_stats.json"
    stats_path = "#{scale_result_dir}/metric/js/stats.json"
    json_dir = "#{scale_results_parent_dir}/json"
    FileUtils.mkdir_p json_dir
    FileUtils.copy_file global_stats_path, "#{json_dir}/#{scenario.gsub(".json", "global_stats.json")}"
    FileUtils.copy_file stats_path, "#{json_dir}/#{scenario.gsub(".json", "stats.json")}"

    # copy puppet-metrics-collector to iteration result dir
    copy_puppet_metrics_collector(scale_result_dir)

    # copy puppet-metrics-collector to parent results dir
    copy_puppet_metrics_collector(scale_results_parent_dir)

  end

  # Process the scale results for the current iteration, update the CSV file, fail if KOs are found
  #
  # @author Bill Claytor
  #
  # @param [Hash] scenario_hash The scenario hash for the current scale iteration
  #
  # @return [void]
  #
  # @example
  #   check_scale_results(scenario_hash)
  #
  # TODO: refactor
  #
  def check_scale_results(scenario_hash)
    scenario = scenario_hash[:name]
    scale_scenario_instances = scenario_hash[:instances]
    success = true

    puts "Checking results for scenario: #{scenario}"
    puts

    # stats dir
    scale_results_parent_dir = "results/scale/latest"
    perf_scale_iteration_dir = "#{scale_results_parent_dir}/#{scenario.gsub(".json", "")}"
    js_dir = "#{perf_scale_iteration_dir}/metric/js"

    puts "Checking stats in: #{js_dir}"
    puts

    # global stats
    global_stats_path = "#{js_dir}/global_stats.json"
    global_stats_file = File.read(global_stats_path)
    global_stats_json = JSON.parse(global_stats_file)

    # check the results for KOs (TODO: needed or just use assertion?)
    num_total = global_stats_json["numberOfRequests"]["total"]
    num_ok = global_stats_json["numberOfRequests"]["ok"]
    num_ko = global_stats_json["numberOfRequests"]["ko"]
    puts "Number of requests:"
    puts "total: #{num_total}"
    puts "ok: #{num_ok}"
    puts "ko: #{num_ko}"
    puts

    # stats
    stats_path = "#{js_dir}/stats.json"
    stats_file = File.read(stats_path)
    stats_json = JSON.parse(stats_file)

    # the 'group' name will be something like 'group_nooptestwithout-9eb19'
    group_keys = stats_json['contents'].keys.select { |key| key.to_s.match(/group/) }
    group_node = stats_json['contents'][group_keys[0]]

    # totals row is in the 'stats' node
    totals = group_node['stats']

    # transaction rows are in the 'contents' node
    contents = group_node['contents']

    # get each category
    node = contents[contents.keys[0]]['stats']
    filemeta_pluginfacts = contents[contents.keys[1]]['stats']
    filemeta_plugins = contents[contents.keys[2]]['stats']
    locales = contents[contents.keys[3]]['stats']
    catalog = contents[contents.keys[4]]['stats']
    report = contents[contents.keys[5]]['stats']

    # get atop results
    # get_scale_atop_results
    atop_csv_path = "#{perf_scale_iteration_dir}/master/atop_log_#{scenario.downcase.gsub(".json", "_json")}.csv"
    atop_csv_data = CSV.read(atop_csv_path)

    # results for csv
    results = []
    results << scale_scenario_instances
    results << totals["numberOfRequests"]["ok"]
    results << totals["numberOfRequests"]["ko"]
    results << totals["meanResponseTime"]["total"]
    results << catalog["meanResponseTime"]["total"]
    results << filemeta_plugins["meanResponseTime"]["total"]
    results << filemeta_pluginfacts["meanResponseTime"]["total"]
    results << locales["meanResponseTime"]["total"]
    results << node["meanResponseTime"]["total"]
    results << report["meanResponseTime"]["total"]
    results << atop_csv_data[1][2] # average CPU TODO: verify from atop
    results << atop_csv_data[1][3] # average memory TODO: verify from atop

    # add this row to the csv
    update_scale_results_csv(scale_results_parent_dir, results)

    # allow no more than 10 KOs per iteration; this needs to be last
    if num_ko > 10
      puts "ERROR - more than 10 KOs encountered in scenario: #{scenario}"
      puts "Exiting scale run..."
      puts
      success = false
    end

    return success
  end

  # Add the results for the current scale iteration to the CSV file
  #
  # @author Bill Claytor
  #
  # @param [String] scale_results_parent_dir The results directory for the scale run
  # @param [Array] results The results array to add to the CSV
  #
  # @return [void]
  #
  # @example
  #   update_scale_results_csv(scale_results_parent_dir, results)
  #
  def update_scale_results_csv(scale_results_parent_dir, results)
    CSV.open("#{scale_results_parent_dir}/PERF_SCALE_#{@scale_timestamp}.csv", "a+") do |csv|
      csv << results
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

    # perf results now have a home
    @archive_root = "results/perf/PERF_#{now}"

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

        puts "Value for #{key} is baseline: #{value} Actual: #{assert_value}"
        next if key.to_s.start_with?("process") && key.to_s.end_with?("cpu")
        max_baseline_variance = \
          if key.to_s == 'process_orchestration_services_release_avg_mem'
            15
          else
            10
          end
        if value.is_a? Integer
          assert_later((assert_value - value) / value * 100 <= max_baseline_variance,
                       "The value of #{key} '#{assert_value}' " \
                       "was not within #{max_baseline_variance}% " \
                       "of the baseline '#{value}'")
        end
      end
    end
  end

end

Beaker::TestCase.send(:include, PerfRunHelper)
