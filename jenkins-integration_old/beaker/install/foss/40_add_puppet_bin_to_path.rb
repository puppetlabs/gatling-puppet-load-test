test_name "Add puppet binaries to the $PATH"

hosts.each do |host|
  on(host, 'echo "export PATH=\$PATH:/opt/puppetlabs/puppet/bin" >> ~/.bashrc')
  on(host, 'echo "export PATH=\$PATH:/opt/puppetlabs/server/bin" >> ~/.bashrc')
end
