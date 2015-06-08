require 'json'
require 'set'

## Assumptions:
## 1. CWD is "jenkins-integration"
## 2. Scenario config JSON files in "./config/scenarios/*.json"
## 3. Node config JSON files in "./config/nodes/*.json"

def get_scenario(scenario_id)
  JSON.parse(File.read(File.join('config', 'scenarios', scenario_id + '.json')))
end

def get_node_configs(scenario)
  scenario['nodes'].map do |node|
    config_path = File.join('config', 'nodes', node['node_config'] + '.json')
    JSON.parse(File.read(config_path))
  end
end

def get_modules(node_configs)
  node_configs.reduce(Set.new) do |modules, node_config|
    modules.merge(node_config['modules'])
  end.to_a
end
