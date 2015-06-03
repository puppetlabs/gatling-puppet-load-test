test_name = "Run gatling scenario"

config_path = File.expand_path(
                File.join( '..',
                           'simulation-runner',
                            ENV['PUPPET_GATLING_SIMULATION_CONFIG'] ))

Puppet::Gatling::LoadTest::ScenarioConfig.initialize_config( config_path )

config = Puppet::Gatling::LoadTest::ScenarioConfig.config_instance

filename = ENV['SBT_FILENAME']
workspace = ENV['SBT_WORKSPACE']
master_ip = fact_on master,'ipaddress'

on gatling, %Q{cd #{workspace}/jenkins-integration; scripts/sbt.sh #{config.simulation_id} #{master_ip} #{filename} /root/sbt-launch.jar}
