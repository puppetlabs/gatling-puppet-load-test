require 'puppet/gatling/config'
require 'scooter'

test_name "Classify PE agents via Node Classifier"

def classify_pe_nodes(classifier, nodes)
  production_id = classifier.get_node_group_id_by_name('Production environment')
  nodes = group_by_environment(nodes)
  nodes.each_pair do |env, node_configs|
    node_configs.each do |config|
      classifier.create_new_node_group_model(
        'name' => "#{config['certname']}-group",
        'parent' => production_id,
        'environment' => env,
        'environment_trumps' => true,
        'rule' => ['=', ['trusted', 'certname'], config['certname']],
        'classes' => Hash[config['classes'].map { |klass| [klass, {}] }])
    end
  end
end

scenario_id = ENV['PUPPET_GATLING_SCENARIO']
nodes = node_configs(scenario_id)
classifier = Scooter::HttpDispatchers::ConsoleDispatcher.new(dashboard)
classifier.update_classes()
classify_pe_nodes(classifier, nodes)
