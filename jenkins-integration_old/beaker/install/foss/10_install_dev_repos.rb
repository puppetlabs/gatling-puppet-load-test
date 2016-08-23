test_name "Setup Dev Repositories"
# Add PC1 collection to options
collection_version = ENV['PUPPET_COLLECTION_VERSION'] || "PC1"
opts = options.merge(dev_builds_repos: [collection_version])

step "Setup puppetserver Dev Repository"
puppetserver_version = ENV["PUPPETSERVER_BUILD_VERSION"] || options[:puppetserver_version]

if puppetserver_version
  install_puppetlabs_dev_repo(master, 'puppetserver', puppetserver_version, '/tmp/repo_configs', opts)
else
  abort("Environment variable PUPPETSERVER_BUILD_VERSION or beaker config option 'puppetserver_version' required!")
end

step "Setup puppet-agent Dev Repository"
puppet_build_version = ENV['PUPPET_BUILD_VERSION'] || options[:puppet_version]

if puppet_build_version
  hosts.each do |host|
    install_puppetlabs_dev_repo(host, 'puppet-agent', puppet_build_version, '/tmp/repo_configs', opts)
  end
else
  abort("Environment variable PUPPET_BUILD_VERSION or beaker config option 'puppet_version' required!")
end
