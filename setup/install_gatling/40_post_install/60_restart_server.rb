test_name 'Restart puppet master to pick up configuration changes'

if %w(foss aio).include?(ENV['BEAKER_INSTALL_TYPE'])
  service_name = 'puppetserver'
elsif ENV['BEAKER_INSTALL_TYPE'] == 'pe'
  service_name = 'pe-puppetserver'
end

on(master, "service #{service_name} reload")

logger.notify("Finished restarting service #{service_name}")
