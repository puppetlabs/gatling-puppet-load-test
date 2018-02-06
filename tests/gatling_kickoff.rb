require 'beaker-benchmark'

test_name 'Kickoff Gatling' do

  start_monitoring(master, 'apples to apples perf run', true, 30)

  begin
    step "Execute gatling scenario" do
      on metric, "cd /root/gatling-puppet-load-test/simulation-runner/ && " +
          "PUPPET_GATLING_MASTER_BASE_URL=https://#{master.hostname}:8140 " +
          "PUPPET_GATLING_SIMULATION_CONFIG=config/scenarios/#{ENV['PUPPET_GATLING_SCENARIO']} " +
          "PUPPET_GATLING_SIMULATION_ID=PerfTestLarge sbt run",
         {:accept_all_exit_codes => true}
    end

  ensure
    perf_result = stop_monitoring(master, '/opt/puppetlabs')
    if perf_result
      perf_result.log_summary
      # Write summary results to log so it can be archived
      perf_result.log_csv
    end
  end

end
