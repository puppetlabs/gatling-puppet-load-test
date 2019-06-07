# frozen_string_literal: true

require_relative "helpers/perf_run_helper"

test_name "soak"

teardown do
  perf_teardown
end

# Execute 60 agent runs (hitting the endpoints 300 times) to warm up the JIT before starting our monitoring.
perf_setup("WarmUpJit.json", "PerfTestLarge", "")
stop_monitoring(master, "/opt/puppetlabs")

gatlingassertions = "SUCCESSFUL_REQUESTS=100 " + "MAX_RESPONSE_TIME_AGENT=20000 " + "TOTAL_REQUEST_COUNT=28800 "

# pass in gatling scenario file name and simulation id
perf_setup("Soak.json", "PerfTestLarge", gatlingassertions)

perf_result

assert_all
