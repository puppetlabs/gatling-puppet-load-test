require_relative 'helpers/perf_run_helper'

test_name 'acceptance'

  teardown do
    perf_teardown
  end

  gatlingassertions = "SUCCESSFUL_REQUESTS=100 " + "MAX_RESPONSE_TIME_AGENT=20000 "  + "TOTAL_REQUEST_COUNT=70 "

  # pass in gatling scenario file name, simulation id and gatlingassertions string.
  perf_setup('acceptance.json','PerfTestLarge', gatlingassertions)

  atop_result, gatling_result = perf_result

  # Increasing to 60000 since we are not warming up JIT first.
  step 'max response' do
   assert_later(gatling_result.max_response_time_agent <= 60000, "Max response time per agent run was: #{gatling_result.max_response_time_agent}, expected <= 60000")
  end

  step 'request count' do
    assert_later(gatling_result.request_count == 70, "Total request count is: #{gatling_result.request_count}, expected 70")
  end

  step 'successful requests' do
    assert_later(gatling_result.successful_requests == 100, "Total successful requests was: #{gatling_result.successful_requests}%, expected 100%" )
  end

  step 'average memory' do
    assert_later(atop_result.avg_mem < 3000000, "Average memory was: #{atop_result.avg_mem}, expected < 3000000")
  end

  #This step will only be run if BASELINE_PE_VER has been set.
  step 'baseline assertions' do
    baseline_assert(atop_result, gatling_result)
  end

assert_all





