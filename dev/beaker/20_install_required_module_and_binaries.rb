test_name "Install required binaries and puppet modules"

step "Install git"
on(jenkins, puppet_resource("package git ensure=installed"))

step "Install Puppet modules"
modules = [
  "puppetlabs-firewall",
  "rtyler-jenkins",
  "puppetlabs-inifile",
  "stahnma-epel"
]
modules.each do |module_name|
  on(jenkins, puppet("module install #{module_name}"))
end
