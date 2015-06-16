require 'json'

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
  result = Hash.new { |h, k| h[k] = Array.new }
  node_configs.each do |node_config|
    env = node_config['environment']
    env = 'production' if (env.nil? || env.empty?)
    result[env] += node_config['modules']
  end
  result.values.each &:uniq!
  result
end

def scenario_modules(scenario_id)
  get_modules(get_node_configs(get_scenario(scenario_id)))
end
