# frozen_string_literal: true

step "Upgrade nss to version that is hopefully compatible with jdk version puppetserver will use." do
  variant, = master["platform"].to_array
  case variant
  when /^(debian|ubuntu)$/
    nss_package_name = "libnss3"
  when /^(redhat|el|centos)$/
    nss_package_name = "nss"
  end
  if defined?(nss_package_name)
    master.upgrade_package(nss_package_name)
  else
    Beaker::Log.warn("Don't know what nss package to use for #{variant} so not installing one")
  end
end

step "Install Puppet Server." do
  install_package master, "puppetserver"
end
