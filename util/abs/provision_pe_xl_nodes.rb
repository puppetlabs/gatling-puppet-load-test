# frozen_string_literal: true

# TODO: make this a Bolt task once abs_helper is available as a gem

require "optparse"
require "yaml"
require "json"
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

# Note: looks like 'Store options to a Hash' doesn't work in Ruby 2.3.0.
# https://ruby-doc.org/stdlib-2.6.3/libdoc/optparse/rdoc/OptionParser.html
#  `end.parse!(into: options)`
# TODO: update to use '(into: options)' after Ruby update
# TODO: error when invalid options are specified
# TODO: re-order the options?
OptionParser.new do |opts|
  opts.banner = "Usage: provision_pe_xl_nodes.rb [options]"

  opts.on("-h", "--help", "Display the help text") do
    puts DESCRIPTION
    puts opts
    puts
    exit
  end

  opts.on("--ha", "Specifies that the environment should be set up for HA")

  # TODO: noop and test options are mutually exclusive;
  # error when both are specified?
  #
  # omitted short versions to avoid collisions
  opts.on("--noop", "Run in no-op mode") { options[:noop] = true }
  opts.on("--test", "Use test data rather than provisioning hosts") { options[:test] = true }

  # TODO: this description seems awkward; suggestions?
  opts.on("--ha", "Specifies that the environment should be set up for HA") { options[:ha] = true }

  opts.on("-i", "--id ID", String, "The value for the AWS 'id' tag") do |id|
    options[:id] = id
  end

  # TODO: verify these
  opts.on("-o", "--output_dir DIR", String, "The directory where the Bolt files should be written") do |output_dir|
    options[:output_dir] = output_dir
  end

  opts.on("-v", "--pe_version VERSION", String, "The PE version to install") do |pe_version|
    options[:pe_version] = pe_version
  end

  opts.on("-t", "--type TYPE", String, "The AWS EC2 instance type to provision") do |type|
    options[:type] = type
  end

  opts.on("-s", "--size SIZE", Integer, "The AWS EC2 volume size to specify") do |size|
    options[:size] = size
  end
end.parse!

ROLES_CORE = %w[master
                puppet_db
                compiler_a
                compiler_b].freeze

ROLES_HA = %w[master_replica
              puppet_db_replica].freeze

if options[:ha]
  HA = true
  ROLES = ROLES_CORE + ROLES_HA
else
  HA = false
  ROLES = ROLES_CORE
end

NOOP = options[:noop] || false
TEST = options[:test] || false
PROVISIONING_TXT = NOOP || TEST ? "Would have provisioned" : "Provisioning"

AWS_TAG_ID = options[:id] || "slv"
OUTPUT_DIR = options[:output_dir] || "./"
PE_VERSION = options[:pe_version] || "2019.1.0"

# TODO: allow different type / size for each node?
AWS_INSTANCE_TYPE = options[:type] || "c5.2xlarge"
AWS_VOLUME_SIZE = options[:size] || "80"

# TODO: move to spec when test cases are implemented
# for now this allows testing of the create_pe_xl_bolt_files method without provisioning
TEST_HOSTS_HA = [{ role: "puppet_db", hostname: "ip-10-227-3-22.test.puppet.net" },
                 { role: "compiler_b", hostname: "ip-10-227-1-195.test.puppet.net" },
                 { role: "puppet_db_replica", hostname: "ip-10-227-3-158.test.puppet.net" },
                 { role: "master", hostname: "ip-10-227-3-127.test.puppet.net" },
                 { role: "compiler_a", hostname: "ip-10-227-3-242.test.puppet.net" },
                 { role: "master_replica", hostname: "ip-10-227-1-82.test.puppet.net" }].freeze

TEST_HOSTS_NO_HA = [{ role: "puppet_db", hostname: "ip-10-227-3-22.test.puppet.net" },
                    { role: "compiler_b", hostname: "ip-10-227-1-195.test.puppet.net" },
                    { role: "master", hostname: "ip-10-227-3-127.test.puppet.net" },
                    { role: "compiler_a", hostname: "ip-10-227-3-242.test.puppet.net" }].freeze

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
# TODO: should this use `<<-` vs `<<~`?
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

PROVISION_MESSAGE = <<~PROVISION_MESSAGE

  #{PROVISIONING_TXT} pe_xl nodes with the following options:
    HA: #{HA}
    Output directory for Bolt inventory and parameter files: #{OUTPUT_DIR}
    PE version: #{PE_VERSION}
    AWS EC2 id tag: #{AWS_TAG_ID}
    AWS EC2 instance type: #{AWS_INSTANCE_TYPE}
    AWS EC2 volume size: #{AWS_VOLUME_SIZE}

PROVISION_MESSAGE

NOOP_MESSAGE = "*** Running in no-op mode ***"
NOOP_EXEC = <<~NOOP_EXEC
  Would have called:

    hosts = provision_hosts_for_roles(#{ROLES},
                                      #{AWS_TAG_ID},
                                      #{AWS_SIZE},
                                      #{AWS_VOLUME_SIZE})

  to provision the hosts, then:

    create_pe_xl_bolt_files(hosts, #{OUTPUT_DIR})

  to create the Bolt inventory and parameter files.

NOOP_EXEC

TEST_MESSAGE = "*** Running in test mode ***"

# This is the main entry point to the provision_pe_xl_nodes.rb script
# It provisions EC2 hosts for pe_xl using ABS (via abs_helper)
#
# TODO: more...
#
# @author Bill Claytor
#
# @example
#   provision_pe_xl_nodes
#
def provision_pe_xl_nodes
  puts NOOP_MESSAGE if NOOP
  puts TEST_MESSAGE if TEST
  puts PROVISION_MESSAGE

  # TODO: update provision_hosts_for_roles to generate last_abs_resource_hosts.log
  # and generate Beaker hosts files
  if NOOP
    puts NOOP_EXEC
  else
    hosts = if TEST
              HA ? TEST_HOSTS_HA : TEST_HOSTS_NO_HA
            else
              provision_hosts_for_roles(ROLES, AWS_TAG_ID, AWS_SIZE, AWS_VOLUME_SIZE)
            end

    create_pe_xl_bolt_files(hosts, OUTPUT_DIR)
  end
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

  check_nodes_yaml(output_path) if TEST
end

# Checks the nodes.yaml file to ensure it has been written correctly
#
# @author Bill Claytor
#
# @param [String] file The 'nodes.yaml' file to check
#
# @example
#   check_nodes_yaml(file)
def check_nodes_yaml(file)
  puts "Checking #{file}..."
  puts

  contents = File.read file
  puts contents
  puts

  puts "Parsing YAML..."
  puts

  yaml = YAML.safe_load contents
  puts yaml
  puts

  puts "Verifying YAML..."
  nodes = yaml["groups"][0]["nodes"]

  puts
  puts "Verified parameter 'nodes':"
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

  check_params_json(output_path) if TEST
end

# Checks the params.json file to ensure it has been written correctly
#
# @author Bill Claytor
#
# @param [String] file The 'params.json' file to check
#
# @example
#   check_params_json(file)
def check_params_json(file)
  puts "Checking #{file}..."
  puts

  contents = File.read(file)
  puts contents

  puts "Parsing JSON..."
  puts

  json = JSON.parse contents
  puts json
  puts

  puts "Verifying JSON..."
  install = json["install"]

  puts "Verified parameter 'install': #{install}"
  puts
end

provision_pe_xl_nodes
