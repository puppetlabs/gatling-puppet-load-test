require 'puppet/gatling/config'

test_name 'Restart puppet master to pick up configuration changes'

service_name = get_puppet_server_service_name_from_env()

on(master, "systemctl restart #{service_name}")

Beaker::Log.notify("Finished restarting service #{service_name}")
