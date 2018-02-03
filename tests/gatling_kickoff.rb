step "Execute gatling scenario" do
  on metric, "cd /root/gatling-puppet-load-test/simulation-runner/ && " +
      "PUPPET_GATLING_MASTER_BASE_URL=https://#{master.hostname}:8140 " +
      "PUPPET_GATLING_SIMULATION_CONFIG=config/scenarios/ApplesToApples.json " +
      "PUPPET_GATLING_SIMULATION_ID=PerfTestLarge sbt run"
end
