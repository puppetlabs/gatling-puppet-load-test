require 'net/http'

test_name 'install Puppet dev repos' do
  skip_test 'Installing PE, not FOSS' unless ENV['BEAKER_INSTALL_TYPE'] == 'foss'

  @install_opts = options.merge( { :dev_builds_repos => ["PC1"] })
  repo_config_dir = 'tmp/repo_configs'

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

  def get_latest_server_version(version)
    response = Net::HTTP.get(URI(BASE_URL + '/puppetserver/?C=M&O=D'))

    # Scrape the puppetserver repo page for available puppetserver builds and
    # filter down to only ones matching the specified branch.  The list of builds
    # is ordered from most recent to oldest.  The resulting list is passed along
    # to the get_cent7_repo routine, which returns a URL for the first build which
    # has a cent7 repo in it.
    get_cent7_repo(
        response.lines.
            select { |l| l =~ /<td><a / }.
            select { |l| l =~ /">.*#{version}.*\/<\/a>/}, "puppetserver")
  end

  def get_latest_agent_version
    url = "http://builds.delivery.puppetlabs.net/passing-agent-SHAs/api/v1/json/report-master"

    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)

    if response.code == "200"
      json = JSON.parse(response.body)
      @install_opts[:puppet_agent_commit] = json["suite-commit"].strip
      @install_opts[:puppet_agent_version] = json["suite-version"].strip
    else
      Beaker::Log.notify("Unable to get last successful build from: #{url}, " +
                             "error: #{response.code}, #{response.message}")
      nil
    end
  end

  def get_latest_release_agent_version
    response = Net::HTTP.get(URI(BASE_URL + '/puppet-agent/?C=M&O=D'))

    # Scrape the puppet-agent repo page for available puppet-agent builds and
    # filter down to only released builds (e.g., 1.2.3) vs.
    # some mergely/SHA version.  The list of builds is ordered from most recent to
    # oldest.  The resulting list is passed along to the get_cent7_repo routine,
    # which returns a URL for the first build which has a cent7 repo in it.
    opts[:puppet_agent_version] = get_cent7_repo(
        response.lines.
            select { |l| l =~ /<td><a / }.
            select { |l| l.match(/^.*href="(\d+\.\d+\.\d+)\/\?C=M&amp;O=D".*$/) },
        "puppet-agent")
  end

  # Mostly copied from: install_puppet_agent_dev_repo_on in Beaker's foss_utils.rb
  def install_puppet_agent_dev_repo_from_local_file( host, opts )
    opts[:copy_base_local]    ||= File.join('tmp', 'repo_configs')
    opts = FOSS_DEFAULT_DOWNLOAD_URLS.merge(opts)

    variant, version, arch, codename = host['platform'].to_array
    add_role(host, 'aio') #we are installing agent, so we want aio role
    copy_dir_local = File.join(opts[:copy_base_local], variant)
    onhost_copy_base = opts[:copy_dir_external] || host.external_copy_base

    release_path_end, release_file = host.puppet_agent_dev_package_info(
        "PC1", opts[:puppet_agent_version], opts )
    release_path = "#{opts[:dev_builds_url]}/puppet-agent/#{ opts[:puppet_agent_commit] }/repos/"
    release_path << release_path_end
    logger.trace("#install_puppet_agent_dev_repo_on: dev_package_info, continuing...")

    if variant =~ /eos/
      host.get_remote_file( "#{release_path}/#{release_file}" )
    else
      onhost_copied_file = File.join(onhost_copy_base, release_file)
      fetch_http_file( release_path, release_file, copy_dir_local)
      scp_to host, File.join(copy_dir_local, release_file), onhost_copy_base
    end

    case variant
      when /eos/
        host.install_from_file( release_file )
      when /^(sles|aix|fedora|el|centos)$/
        # NOTE: AIX does not support repo management. This block assumes
        # that the desired rpm has been mirrored to the 'repos' location.
        # NOTE: the AIX 7.1 package will only install on 7.2 with
        # --ignoreos. This is a bug in package building on AIX 7.1's RPM
        if variant == "aix" and version == "7.2"
          aix_72_ignoreos_hack = "--ignoreos"
        end
        on host, "rpm -ivh #{aix_72_ignoreos_hack} #{onhost_copied_file}"
      when /^windows$/
        result = on host, "echo #{onhost_copied_file}"
        onhost_copied_file = result.raw_output.chomp
        msi_opts = { :debug => host[:pe_debug] || opts[:pe_debug] }
        install_msi_on(host, onhost_copied_file, {}, msi_opts)
      when /^osx$/
        host.install_package("puppet-agent-#{opts[:puppet_agent_version]}*")
      when /^solaris$/
        host.solaris_install_local_package( release_file, onhost_copy_base )
    end
    configure_type_defaults_on( host )

  end

  def install_repo_configs(host, buildserver_url, package_name, build_version, copy_dir)
    filename =  "#{package_name}-#{build_version.sub('master.SNAPSHOT', 'master-0.1SNAPSHOT')}.el7.noarch.rpm"
    repo_config_folder_url = "%s/%s/%s/repos/el/7/puppet5/x86_64" %
        [ buildserver_url, package_name, build_version ]

    puppetserver_installer_url = "#{ repo_config_folder_url }/#{ filename }"
    Beaker::Log.info puppetserver_installer_url
    system "curl -O #{puppetserver_installer_url}"
    scp_to host, filename, "/tmp/#{filename}"
    on host, "yum install -y /tmp/#{filename}"
  end

  step "Setup Puppet agents" do
    puppet_agent_version = ENV['PUPPET_AGENT_VERSION']

    case puppet_agent_version
      when "latest"
        get_latest_agent_version
      when "latest-release"
        get_latest_release_agent_version
    end

    if @install_opts[:puppet_agent_version]
      Beaker::Log.notify("Installing OSS Puppet AGENT version '#{@install_opts[:puppet_agent_version]}'")
      #install_puppet_agent_dev_repo_on hosts, @install_opts
      hosts.each do |host|
        install_puppet_agent_dev_repo_from_local_file host, @install_opts
      end
    else
      abort("Environment variable PUPPET_AGENT_VERSION required for package installs!")
    end
  end

  step "Setup Puppet Server." do
    package_build_version = ENV['PACKAGE_BUILD_VERSION']

    if package_build_version == "latest"
      Beaker::Log.notify("Looking for the very latest Puppet Server build")
      package_build_version = "master"
    end

    if ((package_build_version =~ /SNAPSHOT$/) ||
        (package_build_version == "master"))
      package_build_version = get_latest_server_version(package_build_version)
    end

    if package_build_version
      Beaker::Log.notify("Installing OSS Puppet Server version '#{package_build_version}'")
      install_puppetlabs_dev_repo master, 'puppetserver', package_build_version,
                                  repo_config_dir, @install_opts
    else
      abort("Environment variable PACKAGE_BUILD_VERSION required for package installs!")
    end

    on master, 'puppet resource service puppetserver ensure=running enable=true'
  end

  step "Sign agent certificates" do
    # Failed agent run will request a certificate
    on agents, 'puppet agent -t', {:accept_all_exit_codes => true}
    on master, 'puppet cert sign --all'
  end

end
