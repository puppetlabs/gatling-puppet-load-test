# frozen_string_literal: true

require "optparse"
require "yaml"
require "./setup/helpers/abs_helper.rb"
include AbsHelper # rubocop:disable Style/MixinUsage

DESCRIPTION = <<~DESCRIPTION
  This script was created to assist in working with the pe_xl module (https://github.com/reidmv/reidmv-pe_xl).
  It provisions the nodes used by the module and generates the Bolt inventory and parameter files populated with the provisioned hosts.

  * Note: Because the script is designed to work with GPLT it sets up the environment without HA by default.

  EC2 hosts are provisioned for the following roles:
  * Core roles:
   - master
   - puppet_db
   - compiler_a
   - compiler_b

  * HA roles:
   - master_replica
   - puppet_db_replica

DESCRIPTION

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: provision_pe_xl_nodes.rb [options]"

  # TODO: order?

  opts.on("-h", "--help", "Display the help text") do
    puts DESCRIPTION
    puts opts
    puts
    exit
  end

  # TODO: description seems awkward; suggestions?
  opts.on("--ha HA", TrueClass, "Whether the environment should be set up for HA")

  opts.on("-i", "--id ID", String, 'The value for the AWS "id" tag')

  # TODO: verify these
  opts.on("-o", "--output_dir DIR", String, "The directory where the Bolt files should be written")
  opts.on("-v", "--pe_version VERSION", String, "The PE version to install")
  opts.on("-t", "--type TYPE", String, "The AWS EC2 instance type to provision")
  opts.on("-s", "--size SIZE", Integer, "The AWS EC2 volume size to specify")
end.parse!(into: options)

ROLES_CORE = %w[master
                puppet_db
                compiler_a
                compiler_b].freeze

ROLES_HA = %w[master_replica
              puppet_db_replica].freeze

# TODO: update to use OptionParser
# NOTE: set HA to false for a non-HA environment
HA = options[:ha] || false
ROLES = if HA
          ROLES_CORE + ROLES_HA
        else
          ROLES_CORE
        end

# TODO: update to use OptionParser
# currently uses ARGV[0], ARGV[1] if specified, otherwise these defaults
AWS_TAG_ID = options[:id] || "slv"
OUTPUT_DIR = options[:output_dir] || "./"

# TODO: update to use OptionParser
PE_VERSION = options[:pe_version] || "2019.1.0"

# TODO: allow different type / size for each node?
AWS_INSTANCE_TYPE = options[:type] || "c5.2xlarge"
AWS_VOLUME_SIZE = options[:size] || "80"

# TODO: move to spec when test cases are implemented
# for now this allows testing of the create_pe_xl_bolt_files method without provisioning
TEST_HOSTS_HA = [{ role: "puppet_db", hostname: "ip-10-227-3-22.amz-dev.puppet.net" },
                 { role: "compiler_b", hostname: "ip-10-227-1-195.amz-dev.puppet.net" },
                 { role: "puppet_db_replica", hostname: "ip-10-227-3-158.amz-dev.puppet.net" },
                 { role: "master", hostname: "ip-10-227-3-127.amz-dev.puppet.net" },
                 { role: "compiler_a", hostname: "ip-10-227-3-242.amz-dev.puppet.net" },
                 { role: "master_replica", hostname: "ip-10-227-1-82.amz-dev.puppet.net" }].freeze

TEST_HOSTS_NO_HA = [{ role: "puppet_db", hostname: "ip-10-227-3-22.amz-dev.puppet.net" },
                    { role: "compiler_b", hostname: "ip-10-227-1-195.amz-dev.puppet.net" },
                    { role: "master", hostname: "ip-10-227-3-127.amz-dev.puppet.net" },
                    { role: "compiler_a", hostname: "ip-10-227-3-242.amz-dev.puppet.net" }].freeze

NODES_YAML = <<~NODES_YAML
  ---
  groups:
    - name: pe_xl_nodes
      config:
        transport: ssh
        ssh:
          host-key-check: false
          user: centos
          run-as: root
          tty: true
NODES_YAML

# TODO: update to use variables / symbols for all parameter values?
PARAMS_JSON = <<~PARAMS_JSON
  {
    "install": true,
    "configure": true,
    "upgrade": false,
    "ha": #{HA},

    "master_host": "$MASTER$",
    "puppetdb_database_host": "$PUPPET_DB$",
    "master_replica_host": "$MASTER_REPLICA$",
    "puppetdb_database_replica_host": "$PUPPET_DB_REPLICA$",
    "compiler_hosts": [
      "$COMPILER_A$",
      "$COMPILER_B$"
    ],

    "console_password": "puppetlabs",
    "dns_alt_names": [ "puppet", "$MASTER$" ],
    "compiler_pool_address": "$MASTER$",
    "version": "#{PE_VERSION}"
  }

PARAMS_JSON

def provision_pe_xl_nodes
  puts "Provisioning pe_xl nodes with the following options:"
  puts "  HA: #{HA}"
  puts "  Output directory for Bolt inventory and parameter files: #{OUTPUT_DIR}"
  puts "  PE version: #{PE_VERSION}"
  puts "  AWS EC2 id tag: #{AWS_TAG_ID}"
  puts "  AWS EC2 instance type: #{AWS_INSTANCE_TYPE}"
  puts "  AWS EC2 volume size: #{AWS_VOLUME_SIZE}"
  puts

  # TODO: update provision_hosts_for_roles to generate last_abs_resource_hosts.log
  # # and generate Beaker hosts files
  hosts = provision_hosts_for_roles(ROLES, AWS_TAG_ID, AWS_SIZE, AWS_VOLUME_SIZE)
  create_pe_xl_bolt_files(hosts, OUTPUT_DIR)
end

# Creates the Bolt inventory file (nodes.yaml) and
# parameters file (params.json) for the specified hosts
#
# Note: designed to use the output of provision_hosts_for_roles
#
# @author Bill Claytor
#
# @param [Array<Hash>] hosts The provisioned hosts
# @param [String] output_dir The directory where the file should be written
#
# @example
#   hosts = provision_hosts_for_roles(roles)
#   create_pe_xl_bolt_files(hosts)
#
# TODO: move to abs_helper or elsewhere?
# TODO: spec test(s)
def create_pe_xl_bolt_files(hosts, output_dir)
  create_nodes_yaml(hosts, output_dir)
  create_params_json(hosts, output_dir)
end

# Creates the Bolt inventory file (nodes.yaml) for the specified hosts
#
# Note: designed to use the output of provision_hosts_for_roles
#
# @author Bill Claytor
#
# @param [Array<Hash>] hosts The provisioned hosts
# @param [String] output_dir The directory where the file should be written
#
# @example
#   hosts = provision_hosts_for_roles(roles)
#   create_nodes_yaml(hosts, output_dir)
def create_nodes_yaml(hosts, output_dir)
  yaml = YAML.safe_load NODES_YAML
  output_path = "#{File.expand_path(output_dir)}/nodes.yaml"
  nodes = []

  hosts.each do |host|
    nodes << host[:hostname]
  end

  yaml["groups"][0]["nodes"] = nodes

  puts "Writing #{output_path}"
  puts

  File.write(output_path, YAML.dump(yaml))
end

# Checks the nodes.yaml file to ensure it has been written correctly
#
# @author Bill Claytor
#
# @param [String] file The 'nodes.yaml' file to check
#
# @example
#   check_nodes_yaml(output_dir)
def check_nodes_yaml(file)
  puts "Checking #{file}"

  yaml = YAML.load_file file
  nodes = yaml["groups"][0]["nodes"]

  puts
  puts "nodes:"
  puts nodes
  puts
end

# Creates the Bolt parameters file (params.json) for the specified hosts
#
# Note: designed to use the output of provision_hosts_for_roles
#
# @author Bill Claytor
#
# @param [Array<Hash>] hosts The provisioned hosts
# @param [String] output_dir The directory where the file should be written
#
# @example
#   hosts = provision_hosts_for_roles(roles)
#   create_params_json(hosts, output_dir)
def create_params_json(hosts, output_dir)
  params_json = PARAMS_JSON
  output_path = "#{File.expand_path(output_dir)}/params.json"

  puts "Replacing parameters in params.json: "

  # replace parameters for each host
  hosts.each do |host|
    hostname = host[:hostname]
    role = host[:role]
    param = "$#{role.upcase}$"

    puts " hostname: #{hostname}, role: #{role}, parameter: #{param}"

    # replace parameters
    params_json = params_json.gsub(param, hostname)
  end

  puts
  puts "Writing #{output_path}"
  puts

  File.write(output_path, params_json)
end

# provision pe_xl nodes
provision_pe_xl_nodes
