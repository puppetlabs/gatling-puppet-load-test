require 'puppet/gatling/config'

test_name 'Install Puppet modules into code-staging directory'

# environmentsdir = '/etc/puppetlabs/code-staging/environments'
# modules = modules_per_environment(node_configs(get_scenario_from_env()))
# install_librarian_puppet(master)
# install_environment_modules(master, modules, environmentsdir)
#
# # Set owner to prevent permissions errors during file sync
# on(master, "chown -R pe-puppet:pe-puppet #{environmentsdir}")
