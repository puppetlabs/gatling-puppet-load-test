test_name "Install Puppet on dev machine"

# NOTE: pinning to old agent version because there is a bug that
#  breaks the voxpupuli archive module on puppet-agent 1.5.0
install_puppet_agent_on(jenkins, :puppet_agent_version => "1.4.1")
