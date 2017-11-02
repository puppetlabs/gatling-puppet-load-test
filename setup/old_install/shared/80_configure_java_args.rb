require 'puppet/gatling/config'

test_name 'Configure java args'

service_name = get_puppet_server_service_name_from_env()
service_config = service_config_name(service_name)
java_args = get_puppet_server_java_args_from_env()

set_service_environment_variable(master, service_config, 'JAVA_ARGS', java_args)
