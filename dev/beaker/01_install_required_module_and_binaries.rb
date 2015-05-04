test_name "Install required binaries and puppet modules"

modules = [
  "rtyler-jenkins",
  "puppetlabs-inifile"
]

hosts.each do |host|
  step "Install git"
  on(host, "puppet resource package git ensure=installed")

  modules.each do |module_name|
    step "Install puppet module: #{module_name}"
    on(host, "puppet module install #{module_name}")
  end
end
