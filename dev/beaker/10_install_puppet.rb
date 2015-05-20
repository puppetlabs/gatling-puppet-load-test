test_name "Install puppet on target machine"

step "Install puppet"
# Installs the latest version
on(dev_machine, install_puppet)
