step "Upgrade nss to version that is hopefully compatible with jdk version puppetserver will use." do
  nss_package=nil
  variant, _, _, _ = master['platform'].to_array
  case variant
  when /^(debian|ubuntu)$/
    nss_package_name="libnss3"
  when /^(redhat|el|centos)$/
    nss_package_name="nss"
  end
  if nss_package_name
    master.upgrade_package(nss_package_name)
  else
    logger.warn("Don't know what nss package to use for #{variant} so not installing one")
  end
end

step "Install Puppet Server." do
  make_env = {
      "prefix" => "/usr",
      "confdir" => "/etc/",
      "rundir" => "/var/run/puppetserver",
      "initdir" => "/etc/init.d",
  }

  install_package master, 'puppetserver'
end
