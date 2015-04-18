test_name "Configure Puppet FOSS"

hosts.each do |host|
  step "Set server to localhost"
  on host, "puppet config set server localhost"

  step "Sign SSL Cert"
  on host, "puppet cert list -a"
end
