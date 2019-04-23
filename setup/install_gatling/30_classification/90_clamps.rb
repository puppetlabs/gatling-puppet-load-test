# frozen_string_literal: true

# Clamps is a module based stress testing tool. It will generate a number of
# users on a system to simulate agents. It will then randomize their puppet
# agent -t times to simulate a large number of agents.
def add_clamps_group_ca(classifier, pe_infra)
  # The Clamps::master class manages auth.conf for the agents - by setting it
  # to allow all.  This is insecure and worth looking at overriding at some
  # point, but this should only be used for metrics / load testing on a private
  # network, so shouldn't be an issue short term.
  clamps_ca_group = {
    'name'    => 'Clamps CA',
    'rule'    => ['or', ['=', 'name', master.node_name]], # pinned node
    'parent'  => pe_infra['id'],
    'classes' => {
      'clamps::master' => {}
    }
  }
  classifier.find_or_create_node_group_model(clamps_ca_group)
end

# Creates a node group for creating the fake agents. This node group should
# match all users that are running as root.
def add_clamps_group_agent(classifier, pe_infra)
  clamps_agents_group = {
    'name'    => 'Clamps - Agent Nodes',
    'rule'    => ['and', ['=', %w[fact id], 'root'], ['=', 'name', metric.node_name]],
    'parent'  => pe_infra['id'],
    'classes' => {
      'clamps::agent' => {
        'amqpass'               => '',
        'master'                => any_hosts_as?(:loadbalancer) ? 'puppet' : master.node_name,
        'nonroot_users'         => options[:scale][:num_nonroot_users]       || 2,
        'daemonize'             => options[:scale][:daemonize]               || false,
        'mco_daemon'            => options[:scale][:mco_daemon],
        'num_facts_per_agent'   => options[:scale][:facts_per_agent]         || 500,
        'percent_changed_facts' => options[:scale][:percent_facts_to_change] || 15,
        'splay'                 => options[:scale][:splay]                   || false,
        'splaylimit'            => options[:scale][:splaylimit]              || false
      }.reject { |_k, v| v.nil? }
    }
  }
  classifier.find_or_create_node_group_model(clamps_agents_group)
end

def add_clamps_group_users(classifier, pe_infra)
  clamps_users_group = {
    'name'    => 'Clamps - Agent Users (non root)',
    'rule'    => ['and', ['not', ['=', %w[fact id], 'root']]],
    'parent'  => pe_infra['id'],
    'classes' => {
      'clamps' => {
        'num_static_files'  => options[:scale][:static_files]  || 20,
        'num_dynamic_files' => options[:scale][:dynamic_files] || 5
      }
    }
  }
  classifier.find_or_create_node_group_model(clamps_users_group)
end

def update_pe_agent_rule_clamps(classifier, pe_agent)
  rules = pe_agent['rule']
  rules << ['not', ['~', %w[fact clientcert], ".*#{metric.node_name}"]]
  rules << ['=', %w[fact id], 'root']
  rules[0] = 'or'
  classifier.update_node_group(pe_agent['id'], 'rule' => rules)
end

def clamps_enabled?
  return false unless options[:scale]

  options[:scale][:num_nonroot_users] ||
    options[:scale][:daemonize] ||
    options[:scale][:static_files] ||
    options[:scale][:dynamic_files]
end

test_name 'Clamps classification' do
  skip_test 'No clamps options specified' unless clamps_enabled?

  classifier = get_classifier

  step 'add clamps classification' do
    pe_infra = classifier.get_node_group_by_name('PE Infrastructure')
    add_clamps_group_ca(classifier, pe_infra)
    add_clamps_group_agent(classifier, pe_infra)
    add_clamps_group_users(classifier, pe_infra)
  end

  step 'remove non-root agents from classification' do
    pe_agent = classifier.get_node_group_by_name('PE Agent')
    update_pe_agent_rule_clamps(classifier, pe_agent)
  end
end
