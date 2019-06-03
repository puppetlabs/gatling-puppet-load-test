# frozen_string_literal: true

require "classification_helper"

# Create the Managed Hosts group in the classifier
# NOTE: This class will NOT purge the entries beaker has made to /etc/hosts
# until "purge" is set to True. Do NOT set "purge" to True until Puppet has had
# enough runs for all the nodes to collect the exported resources. Two hours after
# the cluster has been running should be safe.
def add_hosts_group
  puppet_ip = any_hosts_as?(:loadbalancer) ? loadbalancer.ip : master.ip
  hosts_group = {
    "name"    => "Clamps Managed Hosts",
    "rule"    => ["or", ["=", %w[fact id], "root"]],
    "parent"  => pe_infra_uuid,
    "classes" => {
      "hosts" => {
        "purge_hosts"  => false,
        "collect_all"  => true,
        "host_entries" => {
          "puppet" => { "ip" => puppet_ip }
        }
      }
    }
  }

  dispatcher.find_or_create_node_group_model(hosts_group)
end

test_name "Add Managed Hosts classification" do
  add_hosts_group
end
