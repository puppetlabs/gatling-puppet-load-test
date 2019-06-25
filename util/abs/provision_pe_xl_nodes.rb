# frozen_string_literal: true

require "./setup/helpers/abs_helper.rb"
include AbsHelper # rubocop:disable Style/MixinUsage

# TODO: specify as env variable or arg?
ABS_ID = "slv-473"

# TODO: allow different sizes for each node?
ABS_SIZE = "c5.2xlarge"
ABS_VOLUME_SIZE = "80"

ROLES_CORE = %w[master
                puppet_db
                compiler_a
                compiler_b].freeze

ROLES_HA = %w[master_replica
              puppet_db_replica].freeze

# TODO: specify as env variable or arg?
ROLES = ROLES_CORE + ROLES_HA

# TODO: move to spec when test cases are implemented
# for now this allows testing of the create_pe_xl_bolt_files method without provisioning
TEST_HOSTS = [{ role: "puppet_db", hostname: "ip-10-227-3-22.amz-dev.puppet.net" },
              { role: "compiler_b", hostname: "ip-10-227-1-195.amz-dev.puppet.net" },
              { role: "puppet_db_replica", hostname: "ip-10-227-3-158.amz-dev.puppet.net" },
              { role: "master", hostname: "ip-10-227-3-127.amz-dev.puppet.net" },
              { role: "compiler_a", hostname: "ip-10-227-3-242.amz-dev.puppet.net" },
              { role: "master_replica", hostname: "ip-10-227-1-82.amz-dev.puppet.net" }].freeze

# Creates the Bolt inventory file (nodes.yaml) and
# parameters file (params.json) for the specified hosts
#
# Note: designed to use the output of provision_hosts_for_roles
#
# @author Bill Claytor
#
# @param [Array<Hash>] The hosts
#
# @example
#   hosts = provision_hosts_for_roles(roles)
#   create_pe_xl_bolt_files(hosts)
#
# TODO: move to abs_helper or elsewhere?
# TODO: spec test(s)
def create_pe_xl_bolt_files(hosts)
  template_dir = "./util/abs/templates"

  # HA?
  master_replica = hosts.detect { |m| m[:role] == "master_replica" }
  suffix = if master_replica
             "ha"
           else
             "no_ha"
           end

  # TODO: better alternative to having separate files for ha / no ha?
  nodes_yaml = File.read("#{template_dir}/nodes_#{suffix}.yaml")
  params_json = File.read("#{template_dir}/params_#{suffix}.json")

  # replace parameters for each host
  hosts.each do |host|
    hostname = host[:hostname]
    role = host[:role]
    param = "$#{role.upcase}$"

    puts "Replacing parameters: "
    puts " hostname: #{hostname}"
    puts " role: #{role}"
    puts " parameter: #{param}"
    puts

    # replace parameters
    nodes_yaml = nodes_yaml.gsub(param, hostname)
    params_json = params_json.gsub(param, hostname)
  end

  File.write("nodes.yaml", nodes_yaml)
  File.write("params.json", params_json)
end

hosts = provision_hosts_for_roles(ROLES, ABS_ID, ABS_SIZE, ABS_VOLUME_SIZE)
create_pe_xl_bolt_files(hosts)
