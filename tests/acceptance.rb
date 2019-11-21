# frozen_string_literal: true

require_relative "helpers/perf_run_helper"

test_name "acceptance"

teardown do
  perf_teardown
end

gatlingassertions = "SUCCESSFUL_REQUESTS=100 " + "MAX_RESPONSE_TIME_AGENT=20000 " + "TOTAL_REQUEST_COUNT=60 "

# pass in gatling scenario file name, simulation id and gatlingassertions string.
perf_setup("acceptance.json", "PerfTestLarge", gatlingassertions)

atop_result, gatling_result = perf_result

step "request count" do
  assert_later(gatling_result.request_count == 60,
               "Total request count is: #{gatling_result.request_count}, expected 60")
end

step "successful requests" do
  assert_later(gatling_result.successful_requests == 100,
               "Total successful requests was: #{gatling_result.successful_requests}%, expected 100%")
end

step "average memory" do
  assert_later(atop_result.avg_mem < 3_000_000,
               "Average memory was: #{atop_result.avg_mem}, expected < 3000000")
end

if ENV["BASELINE_PE_VER"]
  step "baseline assertions" do
    baseline_assert(atop_result, gatling_result)
  end
end

assert_all
