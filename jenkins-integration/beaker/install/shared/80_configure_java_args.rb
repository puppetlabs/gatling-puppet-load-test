require 'puppet/gatling/config'
require 'inifile'

test_name 'Configure java args'

def service_config_name(service_name)
  "/etc/sysconfig/#{service_name}"
end

def get_service_config(host, service_name)
  local_service_config_dir = Dir.mktmpdir
  scp_from(host, service_config_name(service_name), local_service_config_dir)
  File.join(local_service_config_dir, service_name)
end

def update_java_args_in_local_config(java_args, local_service_config_path)
  # Replace the existing JAVA_ARGS in the config
  ini_file = IniFile.load(local_service_config_path)
  ini_file['global']['JAVA_ARGS'] = java_args
  ini_file.save

  ini_file_lines = File.readlines(local_service_config_path)
  # Clip the '[global]' section header off of the first line
  File.open(local_service_config_path, 'w') do |f|
    f.puts(ini_file_lines[1..-1])
  end
end

def update_service_config(host, source_path, service_name)
  scp_to(host, source_path, service_config_name(service_name))
  on(host, "chmod 644 #{service_config_name(service_name)}")
end

service_name = get_puppet_server_service_name_from_env()
local_service_config_path = get_service_config(master, service_name)
java_args = get_puppet_server_java_args_from_env()
update_java_args_in_local_config(java_args, local_service_config_path)
update_service_config(master, local_service_config_path, service_name)
