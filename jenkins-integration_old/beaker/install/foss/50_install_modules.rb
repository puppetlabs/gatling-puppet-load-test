require 'puppet/gatling/config'

test_name 'Install Puppet modules into code directory'

modules = modules_per_environment(node_configs(get_scenario_from_env()))
install_librarian_puppet(master)
install_environment_modules(master, modules, '/etc/puppetlabs/code')
