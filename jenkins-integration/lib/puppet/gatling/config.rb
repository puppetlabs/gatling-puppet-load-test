require 'json'
require 'yaml'

# This code is used to read gplt scenario JSON files and allow us to
# automate some of the steps of setting up a testing environment for them;
# e.g. what modules do we need to install, what nodes do we need to classify,
# etc.

# Assumptions:
# 1. CWD is "jenkins-integration"
# 2. Configuration files in "../simulation-runner/config/"
#    * Referred to below as CONFIGS (see configuration_root() function)
# 2. Scenario config JSON files in "CONFIGS/scenarios/*"
#    * Note the '.json' extension should be included in the scenario name
# 3. Node config JSON files in "CONFIGS/nodes/*"
#    * Note the '.json' extension should be included in the node name
# 4. Hiera config YAML files in "CONFIGS/hieras/<hiera>/hiera.yaml"
# 5. Hiera data trees in "CONFIGS/hieras/<hiera>/<datadir(s)>/"
# 6. r10k config YAML files in "CONFIGS/r10ks/<r10k>"
#    * Note the '.yaml' extension should be included in the r10k name

################################################################################
### General

# Returns the base directory root containing configuration files.
# Functions that operate on configuration files should use this as the root
# of the file path.
def configuration_root()
  # Ugh, I hate how we've ended up in this situation where we've split the
  # configuration files and the code that operates on them between
  # simulation-runner/ and jenkins-integration/, and that we have to tie them
  # together like this.
  File.join('..', 'simulation-runner', 'config')
end

################################################################################
### Scenarios

# Returns the $PUPPET_GATLING_SIMULATION_CONFIG variable or throws an error.
def get_scenario_from_env()
  scenario_file = ENV['PUPPET_GATLING_SIMULATION_CONFIG']
  if !scenario_file
    raise 'PUPPET_GATLING_SIMULATION_CONFIG scenario file must be defined'
  end
  scenario_file
end

# Parses the full path to the scenario file as JSON.
# Should be called with the result of the get_scenario_from_env() function.
def parse_scenario_file(scenario_file)
  JSON.parse(File.read(File.join(scenario_file)))
end

################################################################################
### Nodes

# Parses the list of node JSON files referenced in the given scenario.
def parse_node_config_files(scenario)
  scenario['nodes'].map do |node|
    config_path = File.join(configuration_root(), 'nodes', node['node_config'])
    JSON.parse(File.read(config_path))
  end
end

# Returns the list of node configs hashes in the given scenario.
def node_configs(scenario_file)
  parse_node_config_files(parse_scenario_file(scenario_file))
end

# Returns the environment from the node config hash, or 'production'
# if it is nil or empty.
def node_environment(node_config)
  env = node_config['environment']
  (env.nil? || env.empty?) ? 'production' : env
end

# Group the list of node configs into a hash keyed by their environments.
# A nil or empty environment will be interpreted as 'production'.
def group_by_environment(node_configs)
  node_configs.group_by do |config|
    node_environment(config)
  end
end

################################################################################
### Modules

# Install librarian-puppet and its dependencies on host.
def install_librarian_puppet(host)
  gem = '/opt/puppetlabs/puppet/bin/gem'
  on(host, "#{gem} install librarian-puppet -v 2.1.0 --no-document")
  on(host, puppet_resource("package git ensure=installed"))
end

# Returns a Puppetfile in string form from the module configs.
def generate_puppetfile(modules)
  modules.map do |mod|
    directive = "mod '#{mod['name']}'"
    if mod['version']
      directive += ", '#{mod['version']}'"
    elsif mod['path']
      directive += ", :path => '#{mod['path']}'"
    elsif mod['git']
      directive += ", :git => '#{mod['git']}'"
      directive += ", :ref => '#{mod['ref']}'" if mod['ref']
    end
    directive
  end.insert(0, "forge 'https://forgeapi.puppetlabs.com'").join("\n")
end

# Install modules in Puppetfile on host in specific environment.
def run_librarian_puppet(host, environment, puppetfile)
  on(host, "mkdir -p #{environment}/modules")
  create_remote_file(host, "#{environment}/Puppetfile", puppetfile)
  librarian_puppet = '/opt/puppetlabs/puppet/bin/librarian-puppet'
  on(host, "cd #{environment} && #{librarian_puppet} install --verbose")
end

# Given the modules grouped by environment, install them under the
# environmentsdir on the given host.
def install_environment_modules(host, modules, environmentsdir)
  modules.each_pair do |env, mods|
    puppetfile = generate_puppetfile(mods)
    run_librarian_puppet(host, "#{environmentsdir}/#{env}", puppetfile)
  end
end

# Returns a hash from environments to modules; removes duplicate modules.
def modules_per_environment(node_configs)
  node_configs = group_by_environment(node_configs)
  modules = node_configs.map do |env, configs|
    [env, configs.map { |c| c['modules'] }.flatten.uniq]
  end
  Hash[modules]
end

################################################################################
### Hiera

# Returns the path to the local hiera.yaml file for the specified hiera.
def hiera_configpath(hiera)
  File.join(configuration_root(), 'hieras', hiera, 'hiera.yaml')
end

# Returns a list of pairs of datadir filepaths for the given hiera.
# The pairs contain the local and target filepaths, respectively.
def hiera_datadirs(hiera)
  configpath = hiera_configpath(hiera)
  config = YAML.load_file(configpath)
  backends = [config[:backends]].flatten
  datadirs = backends.map { |be| config[be.to_sym][:datadir] }.uniq
  datadirs.map do |datadir|
    localpath = File.join(configuration_root(),
                          'hieras', hiera, File.basename(datadir))
    [localpath, datadir]
  end
end

################################################################################
### r10k

# Returns the path to the local r10k YAML configuration file.
def r10k_configpath(r10k)
  File.join(configuration_root(), 'r10ks', r10k)
end

def get_r10k_config_from_env()
  control_repo = ENV['PUPPET_GATLING_R10K_CONTROL_REPO']
  if !control_repo
    raise 'PUPPET_GATLING_R10K_CONTROL_REPO must be defined'
  end

  basedir = ENV['PUPPET_GATLING_R10K_BASEDIR']
  if !basedir
    raise 'PUPPET_GATLING_R10K_BASEDIR must be defined'
  end

  environments = ENV['PUPPET_GATLING_R10K_ENVIRONMENTS']
  if !environments
    raise 'PUPPET_GATLING_R10K_ENVIRONMENTS must be defined'
  end
  environments = environments.split(",")

  {:control_repo => control_repo,
   :basedir => basedir,
   :environments => environments
  }
end