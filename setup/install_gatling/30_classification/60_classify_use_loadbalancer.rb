# frozen_string_literal: true

require File.expand_path("../../../setup/helpers/perf_helper", __dir__)
Beaker::TestCase.class_eval { include PerfHelper }

test_name "classify and use loadbalancer" do # rubocop:disable Metrics/BlockLength
  skip_test "Not a PE Large/XL Architecture" unless any_hosts_as?(:loadbalancer) && any_hosts_as?(:compile_master)

  step "install puppet on loadbalancer" do
    cmd = frictionless_agent_installer_cmd(loadbalancer, {}, "foobar")
    on(loadbalancer, cmd)
  end

  step "create loadbalancer groups" do
    add_loadbalancer_groups(loadbalancer, compile_master)
  end

  step "add loadbalancer to PE Infra Agent group" do
    group_id = classifier.get_node_group_id_by_name("PE Infrastructure Agent")
    classifier.pin_nodes(group_id, { nodes: [loadbalancer] }.to_json)
  end

  step "export haproxy balancer member resources" do
    on(compile_master,
       puppet_agent("-t --no-use_cached_catalog"),
       acceptable_exit_codes: [0, 2])
  end

  step "setup loadbalancer" do
    step "disable selinux on loadbalancer server" do
      on loadbalancer, "setenforce 0 || true"
    end

    step "install haproxy on loadbalancer" do
      on(loadbalancer, puppet_agent("-t --no-use_cached_catalog"),
         acceptable_exit_codes: [2])
    end
  end

  step "set PE Agent group to use loadbalancer" do
    pe_agent_uuid = classifier.get_node_group_by_name("PE Agent")["id"]
    pe_infra_agent_uuid = classifier.get_node_group_by_name("PE Infrastructure Agent")["id"]

    pe_agent_group = {
      "name"    => "PE Agent",
      "classes" => {
        "puppet_enterprise::profile::agent" => {
          "manage_puppet_conf" => true,
          "server_list"        => ["#{loadbalancer}:8140"],
          "pcp_broker_list"    => ["#{loadbalancer}:8142"]
        }
      }
    }

    # Infra agents would otherwise inherit the config above, so explicitly override it to defaults.
    pe_infra_agent_group = {
      "name"    => "PE Infrastructure Agent",
      "rule"    => ["and", ["not", ["~", %w[fact clientcert], ".*agent.*"]]],
      "classes" => {
        "puppet_enterprise::profile::agent" => {
          "manage_puppet_conf" => true,
          "server_list"        => ["#{master}:8140"],
          "pcp_broker_list"    => ["#{master}:8142"]
        }
      }
    }

    classifier.update_node_group(pe_agent_uuid, pe_agent_group)
    classifier.update_node_group(pe_infra_agent_uuid, pe_infra_agent_group)
  end
end
