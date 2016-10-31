install_opts = options.merge( { :dev_builds_repos => ["PC1"] })
repo_config_dir = 'tmp/repo_configs'

require 'net/http'

BASE_URL = 'http://builds.puppetlabs.lan/puppetserver'

def has_cent7_repo?(version)
  cent7_uri = URI("#{BASE_URL}/#{version}/repo_configs/rpm/pl-puppetserver-#{version}-el-7-x86_64.repo")

  response_code = Net::HTTP.start(cent7_uri.host, cent7_uri.port) do |http|
    http.head(cent7_uri.path).code
  end

  if response_code != "200"
    Beaker::Log.notify("Skipping version #{version} because it doesn't appear to have a cent7 repo")
    false
  else
    Beaker::Log.notify("Found Cent7 repo for version #{version}")
    true
  end
end

def get_latest_master_version(branch)
  response = Net::HTTP.get(URI(BASE_URL + '/?C=M&O=D'))

  if branch == "latest"
    branch = "master"
  end

  response.lines.
      select { |l| l =~ /<td><a / }.
      select { |l| l =~ /#{branch}/}.
      map { |l| l.match(/^.*href="([^"]+)\/\?C=M&amp;O=D".*$/)[1] }.
      find { |v| has_cent7_repo?(v) }
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
  if ["latest","stable","master"].include?(package_build_version)
    package_build_version = get_latest_master_version(package_build_version)
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
