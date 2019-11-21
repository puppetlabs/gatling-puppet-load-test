# frozen_string_literal: true

require_relative "helpers/perf_run_helper"

test_name "apples to apples"

teardown do
  perf_teardown
end

# Execute agent runs to warm up the JIT before starting our monitoring.
perf_setup("WarmUpJit.json", "PerfTestLarge", "")
stop_monitoring(master, "/opt/puppetlabs")

gatlingassertions = "SUCCESSFUL_REQUESTS=100 " + "MAX_RESPONSE_TIME_AGENT=20000 " + "TOTAL_REQUEST_COUNT=28800 "

# pass in gatling scenario file name and simulation id
perf_setup("ApplesToApples.json", "PerfTestLarge", gatlingassertions)

atop_result, gatling_result = perf_result

step "max response" do
  # Temporarily disabling this step until SLV-208 is complete
  # assert_later(gatling_result.max_response_time_agent <= 20000,
  #              "Max response time per agent run was: #{gatling_result.max_response_time_agent}, expected <= 20000")
end

step "successful request percentage" do
  assert_later(gatling_result.successful_requests == 100,
               "Total successful request percentage was: #{gatling_result.successful_requests}%, expected 100%")
end

step "average memory" do
  assert_later(atop_result.avg_mem < 3_000_000, "Average memory was: #{atop_result.avg_mem}, expected < 3000000")
end

if ENV["BASELINE_PE_VER"]
  step "baseline assertions" do
    baseline_assert(atop_result, gatling_result)
  end
end

assert_all
