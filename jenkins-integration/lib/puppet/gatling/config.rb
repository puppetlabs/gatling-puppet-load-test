require 'json'

## Assumptions:
## 1. CWD is "jenkins-integration"
## 2. Scenario config JSON files in "./config/scenarios/*.json"
## 3. Node config JSON files in "./config/nodes/*.json"

def parse_scenario_file(scenario_id)
  JSON.parse(File.read(File.join('config', 'scenarios', scenario_id + '.json')))
end

def parse_node_config_files(scenario)
  scenario['nodes'].map do |node|
    config_path = File.join('config', 'nodes', node['node_config'] + '.json')
    JSON.parse(File.read(config_path))
  end
end

# Returns the list of node configs hashes in the given scenario.
def node_configs(scenario_id)
  parse_node_config_files(parse_scenario_file(scenario_id))
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

# Returns a hash from environments to modules; removes duplicate modules.
def modules_per_environment(node_configs)
  node_configs = group_by_environment(node_configs)
  modules = node_configs.map do |env, configs|
    [env, configs.map { |c| c['modules'] }.flatten.uniq]
  end
  Hash[modules]
end
