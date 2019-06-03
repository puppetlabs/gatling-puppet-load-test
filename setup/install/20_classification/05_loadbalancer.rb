# frozen_string_literal: true

require "classification_helper"

# Creates two node groups in the classifier:
# * HAProxy Loadbalancer
# * HAProxy Exports (Compile Masters)
#
# The first node group, HAProxy Loadbalancer will pin the host with role `loadbalancer`
# and add the class `loadbalancer`. This class is a custom profile class that installs
# and configures HAProxy.
#
# The second node group, HAProxy Exports, will have all the compile masters pinned to it
# and the custom profile "loadbalancer_exports" applied. The class will call haproxy::balancermember
# defined type, which creates an exported resource for the loadbalancer to collect.
def add_loadbalancer_groups
  if any_hosts_as?(:loadbalancer)
    loadbalancer_group = {
      "name"    => "HAProxy Loadbalancer",
      "rule"    => ["or", ["=", "name", loadbalancer.node_name]], # pinned node
      "parent"  => pe_infra_uuid,
      "classes" => {
        "profile::loadbalancer" => {}
      }
    }

    dispatcher.find_or_create_node_group_model(loadbalancer_group)
  end

  return unless any_hosts_as?(:compile_master)

  lb_export_rules = ["or"]
  lb_export_rules += [compile_master].flatten.map do |server|
    ["=", "name", server.node_name]
  end

  loadbalancer_exports_group = {
    "name"    => "Loadbalancer Exports(Compile Masters)",
    "rule"    => lb_export_rules, # pinned node
    "parent"  => pe_infra_uuid,
    "classes" => {
      "profile::loadbalancer_exports" => {}
    }
  }
  dispatcher.find_or_create_node_group_model(loadbalancer_exports_group)
end

test_name "Add Loadbalancer classification" do
  skip_test "No loadbalancers to classify" unless any_hosts_as?(:loadbalancer)

  step "add loadbalancer classification" do
    add_loadbalancer_groups
  end
end

test_name "Setup loadbalancer exports" do
  skip_test "No compile_master" unless any_hosts_as?(:compile_master)

  step "export haproxy balancer member resources" do
    # HAProxy is being defined in site.pp, which was setup during
    # the `setup r10k git repo` test
    on compile_master, puppet_agent("-t"), acceptable_exit_codes: [0, 2]
  end
end

test_name "Setup loadbalancer" do
  skip_test "No loadbalancer" unless any_hosts_as?(:loadbalancer)

  step "disable selinux on loadbalancer server" do
    # CentOS 7 requires selinux to be disabled
    on loadbalancer, "setenforce 0 || true"
  end

  step "install haproxy on loadbalancer" do
    on loadbalancer, puppet_agent("-t"), acceptable_exit_codes: [0, 2]
  end
end
