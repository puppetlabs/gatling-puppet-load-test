test_name "Install required binaries and puppet modules"

modules = [
  "puppetlabs-firewall",
  "rtyler-jenkins",
  "puppetlabs-inifile",
  "stahnma-epel"
]

step "Install git"
on(dev_machine, "puppet resource package git ensure=installed")

modules.each do |module_name|
  step "Install puppet module: #{module_name}"
  on(dev_machine, "puppet module install #{module_name}")
end
