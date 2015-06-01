test_name 'Initialize Gatling Configuration' do

  config_path = File.expand_path(
                  File.join( '..',
                             'simulation-runner',
                              ENV['PUPPET_GATLING_SIMULATION_CONFIG'] ))

  Puppet::Gatling::LoadTest::ScenarioConfig.initialize_config( config_path )

end
