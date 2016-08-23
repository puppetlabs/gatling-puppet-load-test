install_opts = options.merge( { :dev_builds_repos => ["PC1"] })
repo_config_dir = 'tmp/repo_configs'

require 'net/http'

def get_latest_master_version
  response = Net::HTTP.get(URI('http://builds.puppetlabs.lan/puppetserver/?C=M&O=D'))

  response.lines do |l|
    next unless l =~ /<td><a /
    next unless l =~ /master/
    match = l.match(/^.*href="([^"]+)\/\?C=M&amp;O=D".*$/)
    return match[1]
  end
end


def get_latest_agent_version
  response = Net::HTTP.get(URI('http://builds.puppetlabs.lan/puppet-agent/?C=M&O=D'))

  response.lines do |l|
    next unless l =~ /<td><a /
    match = l.match(/^.*href="(\d+\.\d+\.\d+)\/\?C=M&amp;O=D".*$/)
    next unless match
    return match[1]
  end
end



step "Setup Puppet Server repositories." do
  package_build_version = ENV['PACKAGE_BUILD_VERSION']
  if package_build_version == "latest"
    package_build_version = get_latest_master_version()
  end
  if package_build_version
    Beaker::Log.notify("Installing OSS Puppet Server version '#{package_build_version}'")
    install_puppetlabs_dev_repo master, 'puppetserver', package_build_version,
                                repo_config_dir, install_opts
  else
    abort("Environment variable PACKAGE_BUILD_VERSION required for package installs!")
  end
end

step "Setup Puppet repositories" do
  puppet_agent_version = ENV['PUPPET_AGENT_VERSION']
  if puppet_agent_version == "latest"
    puppet_agent_version = get_latest_agent_version()
  end
  if puppet_agent_version
    Beaker::Log.notify("Installing OSS Puppet AGENT version '#{puppet_agent_version}'")
    install_puppetlabs_dev_repo master, 'puppet-agent', puppet_agent_version,
                                repo_config_dir, install_opts
  else
    abort("Environment variable PUPPET_AGENT_VERSION required for package installs!")
  end
end
