test_name "Install MRI Puppet Agents."

hosts.each do |host|
  step "Installing puppet-agent"
  # Installs the version specified by PUPPET_BUILD_VERSION, by virtue
  # of that being the only version available after setting up the dev
  # repos
  install_package host, 'puppet-agent'
end
