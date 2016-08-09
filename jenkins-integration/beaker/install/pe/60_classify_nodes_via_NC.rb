require 'puppet/gatling/config'
require 'scooter'

test_name "Classify PE agents via Node Classifier"

def classify_pe_nodes(classifier, nodes)
  production_id = classifier.get_node_group_id_by_name('Production environment')
  nodes = group_by_environment(nodes)
  nodes.each_pair do |env, node_configs|
    node_configs.each do |config|
      classifier.find_or_create_node_group_model(
        'name' => "#{config['certname_prefix']}-group",
        'parent' => production_id,
        'environment' => env,
        'environment_trumps' => true,
        'rule' => ['~', ['trusted', 'certname'], "#{config['certname_prefix']}.*"],
        'classes' => Hash[config['classes'].map { |klass| [klass, {}] }])
    end
  end
end

# this code gets the list of node -> class name mappings by parsing
#  the g-p-l-t 'scenario' json file.

nodes = node_configs(get_scenario_from_env())
classifier = Scooter::HttpDispatchers::ConsoleDispatcher.new(dashboard)

# Updating classes can take a VERY long time, like the OPS deployment
# which has ~80 environments each with hundreds of classes.
# Set the connection timeout to 60 minutes to accomodate this.
classifier.connection.options.timeout = 3600
classifier.update_classes()

classify_pe_nodes(classifier, nodes)

# TODO validate classes by asking for the classes for the each node and
#      asserting they're the same ones that are in the JSON config
