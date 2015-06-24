test_name "Start gatling scenario"

simulation_id = ENV['GATLING_SIMULATION_ID']
gatling_scenario = ENV['GATLING_SCENARIO']
sut_hostname = ENV['GATLING_SUT_HOSTNAME']

if not simulation_id
  abort "GATLING_SIMULATION_ID environment variable required"
elsif not gatling_scenario
  abort "GATLING_SCENARIO environment variable required"
elsif not sut_hostname
  abort "GATLING_SUT_HOSTNAME environment variable required"
end

repo_url = "https://github.com/puppetlabs/gatling-puppet-load-test.git"
repo_path = "/root/gatling-puppet-load-test_#{simulation_id}"

sbt_path = "#{repo_path}/simulation-runner"

# Sets the environment variables and runs sbt
sbt_command = "PUPPET_GATLING_SIMULATION_CONFIG=config/scenarios/#{gatling_scenario} PUPPET_GATLING_SIMULATION_ID=#{simulation_id} PUPPET_GATLING_MASTER_BASE_URL=#{sut_hostname} sbt run"

# To keep log/result files separate on the gatling machine
step "Clone gatling-puppet-load-test into new folder for this scenario"
on(gatling, "git clone #{repo_url} #{repo_path}")

step "Start gatling with scenario on gatling machine"
# This seems like an ugly but accepted way of starting background tasks over ssh
nohup_cmd = "nohup bash -c 'cd #{sbt_path} && #{sbt_command}' &> #{sbt_path}/sbt.out < /dev/null &"
on(gatling, nohup_cmd)

step "Ensure sbt command is running"
# There's probably a more robust way of making sure the command is running
# successfully, rather than just running at all
on(gatling, "ps aux | grep '#{sbt_command}' | grep -v grep")
