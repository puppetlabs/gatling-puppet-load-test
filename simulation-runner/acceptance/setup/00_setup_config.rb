unless ENV.has_key?("IS_PE")
  fail("Must set environment variable 'IS_PE' to either true or false")
end

test_name = "Initialize Gatling Configuration"
Puppet::Gatling::LoadTest::ScenarioConfig.initialize_config(File.expand_path(File.join("../simulation-runner", ENV['PUPPET_GATLING_SIMULATION_CONFIG'])))

