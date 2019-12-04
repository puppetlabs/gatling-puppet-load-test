# frozen_string_literal: true

require_relative "helpers/perf_run_helper"

test_name "pe trial"

teardown do
  perf_teardown
end

# Setup
## Create variables
atop_result, gatling_result = nil

## Set scenario file for test
scenario_file = "pe-trial.json"

## Get scenario data from scenario config file
scenario_dir = File.expand_path("../simulation-runner/config/scenarios", __dir__)
scenario = JSON.parse(File.read(File.join(scenario_dir, scenario_file)))

## Get sim name and hit count from simulation config file identified in scenario data
sim_dir = File.expand_path("../simulation-runner/src/main/scala/com/puppetlabs/gatling/node_simulations", __dir__)
sim = File.basename(scenario["nodes"][0]["node_config"], ".json")
sim_file = File.join(sim_dir, "#{sim}.scala")
sim_hits = File.read(sim_file).scan(/exec\(http/).count

## Set assertions
## This is where changes should be made
max_avg_mem = 3_000_000
min_success_request_perc = 100
max_response_time = 20_000 # magic
total_request_count = scenario["nodes"][0]["num_instances"] * scenario["nodes"][0]["num_repetitions"] * sim_hits
gatlingassertions = %W[SUCCESSFUL_REQUESTS=#{min_success_request_perc}
                       MAX_RESPONSE_TIME_AGENT=#{max_response_time}
                       TOTAL_REQUEST_COUNT=#{total_request_count}].join " "
## End setup

# pass in gatling scenario file name and simulation id
step "run simulation" do
  perf_setup(scenario_file, sim, gatlingassertions)
  atop_result, gatling_result = perf_result
end

step "max response" do
  assert_later(gatling_result.max_response_time_agent <= max_response_time,
               %W[Max response time per agent run was: #{gatling_result.max_response_time_agent},
                  expected <= #{max_response_time}].join(" "))
end

step "successful request percentage" do
  assert_later(gatling_result.successful_requests >= min_success_request_perc,
               %W[Total successful request percentage was: #{gatling_result.successful_requests}%,
                  expected #{min_success_request_perc}%].join(" "))
end

step "average memory" do
  assert_later(atop_result.avg_mem < max_avg_mem,
               "Average memory was: #{atop_result.avg_mem}, expected < #{max_avg_mem}")
end

if ENV["BASELINE_PE_VER"]
  step "baseline assertions" do
    baseline_assert(atop_result, gatling_result)
  end
end

assert_all
