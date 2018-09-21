require_relative 'helpers/perf_run_helper'

test_name 'opsworks' do
  teardown do
    perf_teardown
  end

  gatlingassertions = "SUCCESSFUL_REQUESTS=100 "

  # pass in gatling scenario file name and simulation id
  perf_setup(ENV['OPSWORKS_SCENARIO'],'OpsWorks', gatlingassertions)

  atop_result, gatling_result = perf_result

  # TODO: When we get the rampup working properly, re-add max response time check
  # step 'max response' do
  #   assert_later(gatling_result.max_response_time_agent <= 20000, "Max response time per agent run was: #{gatling_result.max_response_time_agent}, expected <= 20000")
  # end

  step 'successful request percentage' do
    assert_later(gatling_result.successful_requests == 100, "Total successful request percentage was: #{gatling_result.successful_requests}%, expected 100%" )
  end

  step 'average memory' do
    assert_later(atop_result.avg_mem < 3000000, "Average memory was: #{atop_result.avg_mem}, expected < 3000000")
  end

  # TODO: Record specific results for each of the different opsworks tests (ec2 instance type + catalog size)
  # and add baseline comparisons

  assert_all
end
