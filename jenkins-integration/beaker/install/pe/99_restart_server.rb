test_name 'Restart PE Puppet Server to pick up configuration changes'

service_name = ENV['PUPPET_SERVER_SERVICE_NAME']

on(master, "systemctl restart #{service_name}")

Beaker::Log.notify("Finished restarting service #{service_name}")
