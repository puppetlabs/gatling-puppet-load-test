# frozen_string_literal: true

require "classification_helper"

test_name "Use loadbalancer" do
  skip_test "No loadbalancer" unless any_hosts_as?(:loadbalancer)
  skip_test "Not load balancing core agents" unless options[:scale] && options[:scale][:loadbalance_root_agents]

  pe_agent = dispatcher.get_node_group_by_name("PE Agent")
  pe_infra_agent = dispatcher.get_node_group_by_name("PE Infrastructure Agent")
  lb = find_only_one(:loadbalancer)

  pe_agent_group = {
    "name"    => "PE Agent",
    "classes" => {
      "puppet_enterprise::profile::agent" => {
        "manage_puppet_conf" => true,
        "server_list"        => ["puppet:8140"],
        "pcp_broker_list"    => ["puppet:8142"],
        "pcp_broker_ws_uris" => []
      }
    }
  }

  # Infra agents would otherwise inherit the config above, so explicitly override it to defaults.
  pe_infra_agent_group = {
    "name"    => "PE Infrastructure Agent",
    "classes" => {
      "puppet_enterprise::profile::agent" => {
        "manage_puppet_conf" => false,
        "server_list"        => [],
        "pcp_broker_list"    => ["#{master.hostname}:8142"],
        "pcp_broker_ws_uris" => []

      }
    }
  }

  dispatcher.pin_nodes(pe_infra_agent["id"], nodes: [lb])
  dispatcher.update_node_group(pe_agent["id"], pe_agent_group)
  dispatcher.update_node_group(pe_infra_agent["id"], pe_infra_agent_group)
end
