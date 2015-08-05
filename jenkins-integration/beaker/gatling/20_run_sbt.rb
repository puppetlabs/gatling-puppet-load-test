test_name "Start gatling scenario"

simulation_id = ENV['GATLING_SIMULATION_ID']
gatling_scenario = ENV['GATLING_SCENARIO']
sut_hostname = ENV['GATLING_SUT_HOSTNAME']
workspace = ENV['SBT_WORKSPACE']

if not simulation_id
  abort "GATLING_SIMULATION_ID environment variable required"
elsif not gatling_scenario
  abort "GATLING_SCENARIO environment variable required"
elsif not sut_hostname
  abort "GATLING_SUT_HOSTNAME environment variable required"
elsif not workspace
  abort "SBT_WORKSPACE environment variable required"
end

on(gatling, %Q{cd #{workspace}/simulation-runner;
  export PUPPET_GATLING_SIMULATION_ID=#{simulation_id};
  export PUPPET_GATLING_MASTER_BASE_URL=https://#{sut_hostname}:8140;
  export PUPPET_GATLING_SIMULATION_CONFIG=./config/scenarios/#{gatling_scenario};
  sbt run})
