require_relative 'helpers/perf_run_helper'

test_name 'Scale'

# The assertions that will be specified for each iteration of the scenario
assertions = "SUCCESSFUL_REQUESTS=100 " + "MAX_RESPONSE_TIME_AGENT=20000 "  + "TOTAL_REQUEST_COUNT=28800 "

# The scenario file that will be used as a base to build the auto-scaled scenarios
scenario = ENV["PUPPET_GATLING_SCALE_SCENARIO"] || "Scale.json"

# The scenario id / name that will appear in the results
simulation_id = ENV["PUPPET_GATLING_SCALE_SIMULATION_ID"] || "PerfAutoScale"

# Execute the auto-scaled scenario
scale_setup(scenario, simulation_id, assertions)
