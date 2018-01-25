require 'scooter'

test_name "Classify PE agents via Node Classifier"
  skip_test 'Installing FOSS, not PE' unless ENV['BEAKER_INSTALL_TYPE'] == 'pe'

# Classify any agent with the word 'agent' in it's hostname.
def classify_nodes(classifier)
  classifier.find_or_create_node_group_model(
      'parent' => '00000000-0000-4000-8000-000000000000',
      'name' => 'perf-agent-group',
      'rule' => ['or', ['~', ['fact', 'clientcert'], '.*agent.*'],
                 ['~', ['fact', 'clientcert'], "#{agent.hostname}"]],
      'classes' => { ENV['PUPPET_SCALE_CLASS'] => nil } )
end

classifier = Scooter::HttpDispatchers::ConsoleDispatcher.new(dashboard, {:login => 'admin', :password => 'puppetlabs', :resolve_dns => true})

# Updating classes can take a VERY long time, like the OPS deployment
# which has ~80 environments each with hundreds of classes.
# Set the connection timeout to 60 minutes to accomodate this.
classifier.connection.options.timeout = 3600
classifier.update_classes

classify_nodes(classifier)
