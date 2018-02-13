test_name 'Restart puppet master to pick up configuration changes'

service_name = get_puppet_server_service_name_from_env()

on(master, "service #{service_name} reload")

logger.notify("Finished restarting service #{service_name}")
