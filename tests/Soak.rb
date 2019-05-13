require_relative 'helpers/perf_run_helper'

test_name 'soak'

teardown do
  perf_teardown
end

# Execute 60 agent runs (hitting the endpoints 300 times) to warm up the JIT before starting our monitoring.
perf_setup('WarmUpJit.json','PerfTestLarge', '')
stop_monitoring(master, '/opt/puppetlabs')

gatlingassertions = "SUCCESSFUL_REQUESTS=100 " + "MAX_RESPONSE_TIME_AGENT=20000 "  + "TOTAL_REQUEST_COUNT=28800 "

# pass in gatling scenario file name and simulation id
perf_setup('Soak.json','PerfTestLarge', gatlingassertions)

atop_result, gatling_result = perf_result

# TODO: remove commented steps below

step 'max response' do
  # Temporarily disabling this step until SLV-208 is complete
  # assert_later(gatling_result.max_response_time_agent <= 20000, "Max response time per agent run was: #{gatling_result.max_response_time_agent}, expected <= 20000")
end

step 'successful request percentage' do
  # Temporarily disabling this step for Kearney testing
  # assert_later(gatling_result.successful_requests == 100, "Total successful request percentage was: #{gatling_result.successful_requests}%, expected 100%" )
end

step 'average memory' do
  # Temporarily disabling this step for Kearney testing
  # assert_later(atop_result.avg_mem < 3000000, "Average memory was: #{atop_result.avg_mem}, expected < 3000000")
end

##This step will only be run if BASELINE_PE_VER and has been set.
#step 'baseline assertions' do
#
#  baseline_cpu = baseline_result.baseline_cpu.to_f
#  baseline_memory = baseline_result.baseline_memory.to_f
#  baseline_dsk_write = baseline_result.baseline_memory.to_f
#  baseline_avg_resp_time = baseline_result.baseline_avg_resp_time.to_f
#
#  assert_later((atop_result.avg_cpu.to_f - baseline_cpu) / baseline_cpu * 100 <= 10, "avg_cpu: #{atop_result.avg_cpu} was not within 10% of baseline: #{baseline_cpu}.")
#
#  assert_later((atop_result.avg_mem.to_f - baseline_memory) / baseline_memory * 100 <= 10, "avg_mem: #{atop_result.avg_mem} was not within 10% of baseline: #{baseline_memory}.")
#
#  assert_later((atop_result.avg_disk_write.to_f - baseline_dsk_write) / baseline_dsk_write * 100 <= 10, "avg_dsk_write: #{atop_result.avg_disk_write} was not within 10% of baseline: #{baseline_dsk_write}.")
#
#  assert_later(((gatling_result.avg_response_time.to_f - baseline_avg_resp_time) / baseline_avg_resp_time * 100 <= 10), "avg_resp_time: #{gatling_result.avg_response_time} was not within 10% of baseline: #{baseline_avg_resp_time}.")
#
#end

assert_all
