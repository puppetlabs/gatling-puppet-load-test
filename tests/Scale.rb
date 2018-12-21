require_relative 'helpers/perf_run_helper'

test_name 'Scale'

teardown do
  # TODO: remove?
  # perf_teardown
end

# TODO: remove?
# Execute 60 agent runs to warm up the JIT before starting our monitoring.
# perf_setup('WarmUpJit.json','PerfTestLarge', '')
# stop_monitoring(master, '/opt/puppetlabs')

assertions = "SUCCESSFUL_REQUESTS=100 " + "MAX_RESPONSE_TIME_AGENT=20000 "  + "TOTAL_REQUEST_COUNT=28800 "
scenario = ENV["PUPPET_GATLING_SCALE_SCENARIO"] || "Scale.json"
simulation = ENV["PUPPET_GATLING_SCALE_SIMULATION"] || "PerfTestSmall"

# pass in gatling scenario file name and simulation id
scale_setup(scenario, simulation, assertions)


