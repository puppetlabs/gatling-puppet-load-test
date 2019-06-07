# frozen_string_literal: true

require "puppet/gatling/config"

test_name "Configure jruby jar path"

jruby_jar = ENV["PUPPET_GATLING_JRUBY_JAR"]
service_name = get_puppet_server_service_name_from_env
service_config = service_config_name(service_name)

set_service_environment_variable(master, service_config, "JRUBY_JAR", jruby_jar)
