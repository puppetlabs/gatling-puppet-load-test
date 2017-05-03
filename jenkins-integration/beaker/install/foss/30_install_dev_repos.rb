install_opts = options.merge( { :dev_builds_repos => ["PC1"] })
repo_config_dir = 'tmp/repo_configs'

require 'net/http'

BASE_URL = 'http://builds.puppetlabs.lan'

def has_cent7_repo?(package, version)
  cent7_uri = URI("#{BASE_URL}/#{package}/#{version}/repo_configs/rpm/pl-#{package}-#{version}-el-7-x86_64.repo")

  response_code = Net::HTTP.start(cent7_uri.host, cent7_uri.port) do |http|
    http.head(cent7_uri.path).code
  end

  if response_code != "200"
    Beaker::Log.notify("Skipping #{package} version #{version} because it doesn't appear to have a cent7 repo")
    false
  else
    Beaker::Log.notify("Found Cent7 repo for #{package} version #{version}")
    true
  end
end

def get_cent7_repo(response_lines, package)
  response_lines.
      map { |l| l.match(/^.*href="([^"]+)\/\?C=M&amp;O=D".*$/)[1] }.
      find { |v| has_cent7_repo?(package, v) }
end

def get_latest_master_version(branch)
  response = Net::HTTP.get(URI(BASE_URL + '/puppetserver/?C=M&O=D'))

  if branch == "latest"
    branch = "master"
  end

  # Scrape the puppetserver repo page for available puppetserver builds and
  # filter down to only ones matching the specified branch.  The list of builds
  # is ordered from most recent to oldest.  The resulting list is passed along
  # to the get_cent7_repo routine, which returns a URL for the first build which
  # has a cent7 repo in it.
  get_cent7_repo(
      response.lines.
          select { |l| l =~ /<td><a / }.
          select { |l| l =~ /#{branch}/}, "puppetserver")
end

def get_latest_agent_version
  response = Net::HTTP.get(URI(BASE_URL + '/puppet-agent/?C=M&O=D'))

  # Scrape the puppet-agent repo page for available puppet-agent builds and
  # filter down to only released builds (e.g., 1.2.3) vs.
  # some mergely/SHA version.  The list of builds is ordered from most recent to
  # oldest.  The resulting list is passed along to the get_cent7_repo routine,
  # which returns a URL for the first build which has a cent7 repo in it.
  get_cent7_repo(
      response.lines.
          select { |l| l =~ /<td><a / }.
          select { |l| l.match(/^.*href="(\d+\.\d+\.\d+)\/\?C=M&amp;O=D".*$/) },
      "puppet-agent")
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
