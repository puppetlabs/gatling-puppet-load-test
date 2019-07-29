#!/opt/puppetlabs/puppet/bin/ruby

# frozen_string_literal: true

# TODO: docs
# TODO: spec

require "json"

# TODO: "N/A" or error?
NA = "N/A"
PE_PUPPET_SERVER_CONF = "/etc/puppetlabs/puppetserver/conf.d/pe-puppet-server.conf"
POSTGRES_CONF = Dir.glob("/opt/puppetlabs/server/data/postgresql/*/data/postgresql.conf")[-1]
PUPPET_DB_CONF = "/etc/puppetlabs/puppetdb/conf.d/config.ini"
MIN_DEFAULT_JRUBIES = 1
MAX_DEFAULT_JRUBIES = 4

def puppetserver_jruby_max_active_instances
  if File.exist? PE_PUPPET_SERVER_CONF
    line = File.open(PE_PUPPET_SERVER_CONF).grep(/max-active-instances/)[0]
    value = line.scan(/\d+/).first unless line.nil?
  end

  unless value
    # TODO: eliminate bash
    command = "facter processorcount"
    output = `#{command}`

    if output
      num_cores = output.to_i
      value = [[num_cores, MIN_DEFAULT_JRUBIES].max, MAX_DEFAULT_JRUBIES].min.to_s
    else
      value = NA
    end

  end

  value
end

# TODO: grep for java args
def get_java_args(file)
  path = if File.exist? "/etc/debian_version"
           "/etc/defaults/#{file}"
         else
           "/etc/sysconfig/#{file}"
         end

  value = if File.exist? path
            File.open(path).grep(/Xmx/)[0].split('"')[1]
          else
            NA
          end

  value
end

def puppetserver_reserved_code_cache
  get_java_args("pe-puppetserver").match(/XX:ReservedCodeCacheSize=\K[^\s]+/) || NA
end

def console_java_args
  get_java_args("pe-console-services")
end

def master_java_args
  get_java_args("pe-puppetserver")
end

def orchestrator_java_args
  get_java_args("pe-orchestration-services")
end

def puppetdb_java_args
  get_java_args("pe-puppetdb")
end

def get_conf_parameter(file, parameter, exclusions = NA)
  value = if File.exist? file
            match_val = /#{parameter} = \K[^\s]+/
            File.open(file).grep_v(exclusions).grep(/#{parameter}/).grep_v(/^#/)[0].match(match_val)
          else
            NA
          end
  value
end

def get_postgres_parameter(parameter, exclusions = NA)
  get_conf_parameter(POSTGRES_CONF, parameter, exclusions)
end

def get_puppetdb_parameter(parameter, exclusions = NA)
  get_conf_parameter(PUPPET_DB_CONF, parameter, exclusions)
end

def database_shared_buffers
  get_postgres_parameter("shared_buffers")
end

def database_autovacuum_max_workers
  get_postgres_parameter("autovacuum_max_workers")
end

def database_autovacuum_work_mem
  get_postgres_parameter("autovacuum_work_mem")
end

def database_maintenance_work_mem
  get_postgres_parameter("maintenance_work_mem")
end

def database_max_connections
  get_postgres_parameter("max_connections")
end

def database_work_mem
  exclusions = /(maintenance|autovacuum)/
  get_postgres_parameter("work_mem", exclusions)
end

def puppetdb_command_processing_threads
  get_puppetdb_parameter("threads")
end

# rubocop:disable Metrics/LineLength
def current_settings
  params = []
  params << { "puppet_enterprise::master::puppetserver::jruby_max_active_instances" => puppetserver_jruby_max_active_instances }
  params << { "puppet_enterprise::master::puppetserver::reserved_code_cache" => puppetserver_reserved_code_cache }
  params << { "puppet_enterprise::profile::console::java_args" => console_java_args }
  params << { "puppet_enterprise::profile::database::shared_buffers" => database_shared_buffers }
  params << { "puppet_enterprise::profile::database::autovacuum_max_workers" => database_autovacuum_max_workers }
  params << { "puppet_enterprise::profile::database::autovacuum_work_mem" => database_autovacuum_work_mem }
  params << { "puppet_enterprise::profile::database::maintenance_work_mem" => database_maintenance_work_mem }
  params << { "puppet_enterprise::profile::database::max_connections" => database_max_connections }
  params << { "puppet_enterprise::profile::database::work_mem" => database_work_mem }
  params << { "puppet_enterprise::profile::master::java_args" => master_java_args }
  params << { "puppet_enterprise::profile::orchestrator::java_args" => orchestrator_java_args }
  params << { "puppet_enterprise::profile::puppetdb::java_args" => puppetdb_java_args }
  params << { "puppet_enterprise::puppetdb::command_processing_threads" => puppetdb_command_processing_threads }

  json = JSON.pretty_generate params

  # TODO: optional?
  puts json

  json
end
# rubocop:enable Metrics/LineLength

current_settings
