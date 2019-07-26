# frozen_string_literal: true

require "json"

NA = "N/A"
PE_PUPPET_SERVER_CONF = "/etc/puppetlabs/puppetserver/conf.d/pe-puppet-server.conf"
POSTGRES_CONF = "/opt/puppetlabs/server/data/postgresql/9.6/data/postgresql.conf"
PUPPET_DB_CONF = "/etc/puppetlabs/puppetdb/conf.d/config.ini"

def puppetserver_jruby_max_active_instances
  if File.exist? PE_PUPPET_SERVER_CONF
    command = "cat #{PE_PUPPET_SERVER_CONF} | grep max-active-instances | egrep -v '^#' | cut -d ':' -f 2"
    output = `#{command}`.strip!
    value = output.to_i unless output.nil? || output.empty?
  end

  unless value
    command = "facter processorcount"
    output = `#{command}`

    if output
      num_cores = output.to_i
      minimum = 1
      maximum = 4
      value = [[num_cores, minimum].max, maximum].min
    else
      value = NA
    end

  end

  value
end

def get_java_args(file)
  path = if File.exist? "/etc/debian_version"
           "/etc/defaults/#{file}"
         else
           "/etc/sysconfig/#{file}"
         end

  if File.exist? path
    command = "cat #{path} | grep Xmx | grep Xmx"
    output = `#{command}`
    value = output.split('"')[1] if output
  else
    value = NA
  end

  value
end

def puppetserver_reserved_code_cache
  path = if File.exist? "/etc/debian_version"
           "/etc/defaults/pe-puppetserver"
         else
           "/etc/sysconfig/pe-puppetserver"
         end

  if File.exist? path
    command = "cat #{path} | grep Xmx | grep Xmx"
    res_param = nil

    output = `#{command}`
    output.split(" ").each do |param|
      if param.include? "ReservedCodeCacheSize"
        res_param = param
        break
      end
    end

    value = res_param.split("=")[1] if res_param
  else
    value = NA
  end

  value
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

# TODO: add exclude arg
def get_postgres_parameter(parameter)
  command = "cat #{POSTGRES_CONF} | grep #{parameter} | egrep -v '^#' | cut -d '=' -f 2 | cut -d '#' -f 1"
  `#{command}`.strip!
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

# TODO: use get_postgres_parameter once updated to take exlude arg
def database_work_mem
  exclusion = "grep -v -e 'maintenance' -e 'autovacuum'"
  command = "cat #{POSTGRES_CONF} | grep work_mem | #{exclusion} | egrep -v '^#' | cut -d '=' -f 2 | cut -d '#' -f 1"
  `#{command}`.strip!
end

def puppetdb_command_processing_threads
  command = "cat #{PUPPET_DB_CONF} | grep threads | egrep -v '^#' | cut -d '=' -f 2"
  `#{command}`.strip!
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
  params << { "puppet_enterprise::profile::database::maintenance_work_mem" => database_maintenance_work_mem }
  params << { "puppet_enterprise::profile::database::max_connections" => database_max_connections }
  params << { "puppet_enterprise::profile::database::work_mem" => database_work_mem }
  params << { "puppet_enterprise::profile::master::java_args" => master_java_args }
  params << { "puppet_enterprise::profile::orchestrator::java_args" => orchestrator_java_args }
  params << { "puppet_enterprise::profile::puppetdb::java_args" => puppetdb_java_args }
  params << { "puppet_enterprise::puppetdb::command_processing_threads" => puppetdb_command_processing_threads }

  # TODO: pretty or not?
  # json = params.to_json
  json = JSON.pretty_generate params

  # TODO: remove?
  puts json

  json
end
# rubocop:enable Metrics/LineLength

current_settings
