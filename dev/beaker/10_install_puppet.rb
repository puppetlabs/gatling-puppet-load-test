test_name "Install puppet on target machine"

puppet_version = "3.7.5"

step "Install puppet"
on(dev_machine, install_puppet({:version => puppet_version}))
