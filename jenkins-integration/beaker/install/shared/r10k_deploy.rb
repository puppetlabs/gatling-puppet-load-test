require 'puppet/gatling/config'

test_name "Deploy r10k control repository"

## TODO This probably needs more work to finish hooking up everything that
##      comes in the control repository, like a hiera.yaml config file.
##
##      Also, r10k will manage the entire environment directory, which means
##      previous gatling installation steps (e.g. 50_install_modules.rb) may
##      be overridden. For example, any modules defined in the JSON node files
##      that aren't defined in the r10k control repo will be removed.

def install_r10k(host)
  gem = '/opt/puppetlabs/puppet/bin/gem'
  on(host, "#{gem} install r10k --no-document")
end

def create_r10k_config(host, r10k)
  configfile = r10k_configpath(r10k)
  configdir = '/etc/puppetlabs/r10k'
  on(host, "mkdir -p #{configdir}")
  scp_to(host, configfile, "#{configdir}/r10k.yaml")
end

def run_r10k_deploy(host)
  r10k = '/opt/puppetlabs/puppet/bin/r10k'
  on(host, "#{r10k} deploy environment --puppetfile --verbose")
end

scenario_id = ENV['PUPPET_GATLING_SCENARIO']
r10k_config = parse_scenario_file(scenario_id)['r10k']
if r10k_config
  install_r10k(master)
  create_r10k_config(master, r10k_config)
  run_r10k_deploy(master)
end
