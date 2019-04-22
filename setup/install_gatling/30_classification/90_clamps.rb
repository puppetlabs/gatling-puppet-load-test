# Clamps is a module based stress testing tool. It will generate a number of
# users on a system to simulate agents. It will then randomize their puppet
# agent -t times to simulate a large number of agents.
def add_clamps_groups
  classifier = get_classifier
  pe_infra_group = classifier.get_node_group_by_name('PE Infrastructure')
  pe_infra_uuid = pe_infra_group['id']
  # Creates a node group for creating the fake agents. This node group should match all users that are
  # running as root.
  clamps_agents_group = {
    'name'    => "Clamps - Agent Nodes",
    "rule"    =>  [ "and", [ "=", [ "fact", "id" ], "root" ], [ "~", [ "fact", "fqdn" ], "agent" ] ],
    'parent'  => pe_infra_uuid,
    'classes' => {
      'clamps::agent' => {
        'master'                => any_hosts_as?(:loadbalancer) ? 'puppet' : master.node_name,
        'nonroot_users'         => (options[:scale] && options[:scale][:num_nonroot_users])       || 2,
        'daemonize'             => (options[:scale] && options[:scale][:daemonize])               || false,
        'mco_daemon'            => (options[:scale] && options[:scale][:mco_daemon])              || 'stopped',
        'num_facts_per_agent'   => (options[:scale] && options[:scale][:facts_per_agent])         || 500,
        'percent_changed_facts' => (options[:scale] && options[:scale][:percent_facts_to_change]) || 15,
        'splay'                 => (options[:scale] && options[:scale][:splay])                   || false,
        'splaylimit'            => (options[:scale] && options[:scale][:splaylimit])              || false,
      },
    }
  }

  # Create static and dynamic files for the non-root user agents
  clamps_users_group = {
    'name'    => "Clamps - Agent Users (non root)",
    "rule"    =>  [ "and", [ "not", [ "=", [ "fact", "id" ], "root" ]]],
    'parent'  => pe_infra_uuid,
    'classes' => {
      'clamps' => {
        'num_static_files' => (options[:scale] && options[:scale][:static_files]) || 20,
        'num_dynamic_files' => (options[:scale] && options[:scale][:dynamic_files]) || 5,
      }
    },
  }

  # The Clamps::master class manages auth.conf for the agents - by setting it to allow all.
  # This is insecure and worth looking at overriding at some point, but this should only be used for
  # metrics / load testing on a private network, so shouldn't be an issue short term.
  clamps_ca_group = {
    'name'    => "Clamps CA",
    'rule'    => ["or", ["=", "name", master.node_name]], # pinned node
    'parent'  => pe_infra_uuid,
    'classes' => {
      'clamps::master' => {}
    },
  }

  classifier.find_or_create_node_group_model(clamps_agents_group)
  classifier.find_or_create_node_group_model(clamps_users_group)
  classifier.find_or_create_node_group_model(clamps_ca_group)
end

def add_root_only_rule
  classifier = get_classifier
  # Modifies the PE Node Groups "PE Agent" so
  # they do not get applied to non-root agents
  pe_agent = classifier.get_node_group_by_name('PE Agent')

  pe_agent_group = {
    'name' => "PE Agent",
    'rule' => pe_agent["rule"] << ["=", [ "fact", "id" ], "root"],
  }

  classifier = get_classifier
  classifier.update_node_group(pe_agent['id'], pe_agent_group)
end

def clamps_enabled?
  return false unless options[:scale]

  options[:scale][:num_nonroot_users] ||
    options[:scale][:daemonize] ||
    options[:scale][:static_files] ||
    options[:scale][:dynamic_files]
end

test_name 'Clamps classification' do
  skip_test "No clamps options specified" unless clamps_enabled?

  step 'add clamps classification' do
    add_clamps_groups
  end

  step 'remove non-root agents from classification' do
    add_root_only_rule
  end

end
