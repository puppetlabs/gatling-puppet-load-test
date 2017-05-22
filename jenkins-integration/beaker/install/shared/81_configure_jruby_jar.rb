require 'puppet/gatling/config'

test_name 'Configure jruby jar path'

def service_config_name(service_name)
  "/etc/sysconfig/#{service_name}"
end

def set_bash_variable(host, filepath, variable_name, value)
  manifest = <<-MANIFEST
ini_setting { "#{variable_name}":
  ensure  => present,
  path    => "#{filepath}",
  section => "",
  setting => "#{variable_name}",
  key_val_separator => "=",
  value   => "#{value}",
}
  MANIFEST

  on host, puppet('apply', '-e', "'#{manifest}'")
end

jruby_jar = ENV['PUPPET_GATLING_JRUBY_JAR']

service_name = get_puppet_server_service_name_from_env()
service_config = service_config_name(service_name)

set_bash_variable(master, service_config, 'JRUBY_JAR', jruby_jar)
