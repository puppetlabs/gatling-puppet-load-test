require 'scooter'
require 'tmpdir'
require 'yaml'
require 'beaker'
require 'net/http'
require 'beaker-pe' #PE-25240 will make this not needed

module PerfHelper
  BASE_URL = 'http://builds.puppetlabs.lan'
  R10K_DIR = '/opt/puppetlabs/scratch/perf_testing/r10k'
  R10K_CONFIG_PATH = "#{R10K_DIR}/r10k.yaml"

  def set_etc_hosts
    puppet_ip = any_hosts_as?(:loadbalancer) ? loadbalancer.ip : master.ip
    on hosts, %Q{echo "#{puppet_ip} puppet" >> /etc/hosts}
  end

  def install_epel_packages
    # Yum returns 1 if a package is already installed and we try to install
    # it, so just always return true when adding a repo or installing a
    # package for the metrics stuff.

    step 'add epel' do
      # Graphite / grafana needs a newer version of python which is only found in the epel repo
      # Also needed for newer version of atop
      hosts.each do |host|
        platform_ver = host['platform'].version
        epel_url = "https://dl.fedoraproject.org/pub/epel/epel-release-latest-#{platform_ver}.noarch.rpm"
        host.install_package(epel_url, '', nil, :acceptable_exit_codes => [0,1])
      end
    end

    step 'disable selinux on metrics server' do
      # disable selinux immediately, but not persistent after a reboot
      on agents, 'setenforce 0 || true'
      # required to disable selinux between reboots
      on agents, "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux" unless
          agents[0]['template'] == 'amazon-6-x86_64'
    end

    step 'install nc for agents to report run times to graphite' do
      on agents, 'yum install -y nc || true'
    end

    step 'ensure iptables chkconfig is disabled on el6' do
      hosts.each { |host|
        if host['platform'] == 'el-6-x86_64'
          on host, 'chkconfig iptables off'
        end
      }
    end
  end

  def setup_r10k
    # Get all hosts with role master or compile_master
    masters = select_hosts({:roles => ['master', 'compile_master']})

    step 'install git on masters for file syncing' do
      # vcloud VM's do not have git installed
      masters.each do |node|
        install_package node, 'git'
      end
    end
  end

  def download_file(url, destination)
    raise "Specified URL does not exist: #{url}" unless link_exists?(url)
    puts "Downloading #{url} to #{destination}"
    download = open(url)
    IO.copy_stream(download, destination)
    raise "Download was not successful" unless File.exists?(destination)
  end

  def perf_install_pe
    if !is_pre_aio_version?
      # Must include the dashboard so that split installs add these answers to classification
      r10k_remote = '/opt/puppetlabs/server/data/puppetserver/r10k/control-repo'
      @options[:answers] ||= {}
      @options[:answers]['puppet_enterprise::profile::master::r10k_remote'] = r10k_remote
      @options[:answers]['puppet_enterprise::profile::puppetdb::node_ttl'] = '0s'
    end

    step 'install PE' do
      install_lei
    end
  end

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
      json["suite-commit"].strip
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
    get_cent7_repo(
        response.lines.
            select { |l| l =~ /<td><a / }.
            select { |l| l.match(/^.*href="(\d+\.\d+\.\d+)\/\?C=M&amp;O=D".*$/) },
        "puppet-agent")
  end

  def perf_install_foss
    install_opts = options.merge( { :dev_builds_repos => ["PC1"] })
    repo_config_dir = 'tmp/repo_configs'

    step "Setup Puppet repositories" do
      puppet_agent_version = ENV['PUPPET_AGENT_VERSION']

      case puppet_agent_version
        when "latest"
          puppet_agent_version = get_latest_agent_version
        when "latest-release"
          puppet_agent_version = get_latest_release_agent_version
      end

      if puppet_agent_version
        Beaker::Log.notify("Installing OSS Puppet AGENT version '#{puppet_agent_version}'")
        install_puppetlabs_dev_repo master, 'puppet-agent', puppet_agent_version,
                                    repo_config_dir, install_opts
        install_puppetlabs_dev_repo agent, 'puppet-agent', puppet_agent_version,
                                    repo_config_dir, install_opts
      else
        abort("Environment variable PUPPET_AGENT_VERSION required for package installs!")
      end
    end

    step "Setup Puppet Server repositories." do
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
                                    repo_config_dir, install_opts
      else
        abort("Environment variable PACKAGE_BUILD_VERSION required for package installs!")
      end
    end

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
        Beaker::Log.warn("Don't know what nss package to use for #{variant} so not installing one")
      end
    end

    step "Install Puppet Server." do
      install_package master, 'puppetserver'
      on(master, "puppet config set --section master autosign true")
      on(master, "service puppetserver start")
      on(master, "puppet agent -t --server #{master}")
    end

    step "Install Puppet Agent." do
      install_package agent, 'puppet-agent'
      on(agent, "puppet agent -t --server #{master}")
      on(master, "puppet config remove --section master autosign")
    end

  end

  ## TODO This probably needs more work to finish hooking up everything that
  ##      comes in the control repository.
  ##
  ##      Also, r10k will manage the entire environment directory, which means
  ##      previous gatling installation steps (e.g. 50_install_modules.rb) may
  ##      be overridden. For example, any modules defined in the JSON node files
  ##      that aren't defined in the r10k control repo will be removed.

  def install_r10k(host, bin, r10k_version)
    gem = "#{bin}/gem"
    on(host, "#{gem} install r10k -v #{r10k_version} --no-rdoc --no-ri")
  end

  def create_r10k_config(host, r10k_config)

    on(host, "mkdir -p #{R10K_DIR}")

    cachedir = "#{R10K_DIR}/cache"

    r10k_config_contents = <<EOS
:cachedir: '#{cachedir}'

:sources:
  :perf-test:
    remote: '#{r10k_config[:control_repo]}'
    basedir: '#{r10k_config[:basedir]}'
EOS

    create_remote_file(host, R10K_CONFIG_PATH, r10k_config_contents)
  end

  def run_r10k_deploy(host, bin, environments, exec_options)
    r10k = "#{bin}/r10k"
    results = {}
    environments.each do |env|
      result = on(host, "#{r10k} deploy environment #{env} -p -v debug -c #{R10K_CONFIG_PATH}",
                  exec_options)
      results[env] = result.exit_code
    end
    results
  end

  def r10k_deploy
    bin = ENV['PUPPET_BIN_DIR']
    r10k_version = ENV['PUPPET_R10K_VERSION']

    step "Install and configure r10k" do
      r10k_config = get_r10k_config_from_env()
      if r10k_config
        install_r10k(master, bin, r10k_version)
        create_r10k_config(master, r10k_config)

        # This is straight up horrific.  Sorry.
        # Old versions of r10k can do fun things like throw NPEs and return a non-zero
        # exit code even when they've actually successfully deployed.  If you then
        # simply re-run the same r10k command afterward, it'll get a zero exit code.
        # So, we will do an initial deploy and then if we got any non-zero exit codes,
        # we'll try those environments one more time.  Sorry.
        results = run_r10k_deploy(master, bin, r10k_config[:environments],
                                  {:acceptable_exit_codes => [0, 1]})
        failed_envs = results.select { |env,exit_code| exit_code == 1 }.keys
        if failed_envs.size > 0
          Beaker::Log.warn("R10K deploy failed on environments: #{failed_envs}; trying one more time.")
          run_r10k_deploy(master, bin, failed_envs, {})
        end
      else
        raise "No R10K config found in environment!"
      end
    end

    puppet_module_dependencies
  end

  def puppet_module_dependencies
    # Hacky, but new versions of puppet require different stuff in Puppetfile,
    # for older versions, remove those lines.
    step "Use external puppet modules for puppet >= 6.0" do
      puppet_version = on(master, 'puppet --version').stdout
      if master.version_is_less(puppet_version, "6.0")
        on master, "sed -i '/puppetlabs\\/.*_core/d' /etc/puppetlabs/code-staging/environments/production/Puppetfile"
        on master, "rm -rf /etc/puppetlabs/code-staging/environments/production/modules/*_core"
      end
    end
  end

  def enable_file_sync
    api = Scooter::HttpDispatchers::ConsoleDispatcher.new(dashboard)
    pe_master_group = api.get_node_group_by_name('PE Master')
    pe_master_group['classes']['puppet_enterprise::profile::master']['file_sync_enabled'] = true
    api.replace_node_group(pe_master_group['id'], pe_master_group)
    on(master, 'puppet agent -t', :acceptable_exit_codes => [0,2])
  end

  def sync_code_dir
    # Do a File Sync commit
    curl = 'curl '
    curl += '--cert $(puppet config print hostcert) '
    curl += '--key $(puppet config print hostprivkey) '
    curl += '--cacert $(puppet config print localcacert) '
    curl += '-H "Content-type: application/json" '
    curl += "https://#{master}:8140/file-sync/v1/commit "
    curl += '-d \'{"commit-all": true}\''

    on(master, curl)

    # TODO: DRY
    # This code hits the file sync 'force sync' endpoint, which will hopefully
    # trigger a synchronous sync of the files.  Ideally that means that when
    # this curl command returns, we know that the sync is complete and that the
    # files have been deployed successfully.
    curl = 'curl '
    curl += '-X POST '
    curl += '--cert $(puppet config print hostcert) '
    curl += '--key $(puppet config print hostprivkey) '
    curl += '--cacert $(puppet config print localcacert) '
    curl += '-H "Content-type: application/json" '
    curl += "https://#{master}:8140/file-sync/v1/force-sync "

    on(master, curl)
  end

  def get_classifier
    classifier = Scooter::HttpDispatchers::ConsoleDispatcher.new(dashboard)
    # Updating classes can take a VERY long time, like the OPS deployment
    # which has ~80 environments each with hundreds of classes.
    # Set the connection timeout to 60 minutes to accomodate this.
    classifier.connection.options.timeout = 3600
    classifier.update_classes
    return classifier
  end

  def classify_nodes_via_nc
    # Classify any agent with the word 'agent' in it's hostname.
    # get classifier and set timeout
    classifier = get_classifier
    classifier.find_or_create_node_group_model(
        'parent' => '00000000-0000-4000-8000-000000000000',
        'name' => 'perf-agent-group',
        'rule' => ['~', ['fact', 'clientcert'], '.*agent.*'],
        'classes' => { ENV['PUPPET_SCALE_CLASS'] => nil } )
  end

  def generate_sitepp()
    <<-sitepp
node /.*agent.*/ { include #{ENV['PUPPET_SCALE_CLASS']} }
node 'default' {}
    sitepp
  end

  def classify_foss_nodes(host)
    environments = on(host, puppet('config print environmentpath')).stdout.chomp
    # on old PEs (3.3 at least), directory environments have to be enabled. We
    # can detect this situation because the command above will return an empty
    # string.  In that case we'll take a swing at enabling them by modifying the
    # puppet config file, and then running the command again.
    #
    # This may need to be changed to support more versions of PE and/or OSS in
    # the future.
    if environments == ""
      on(host, puppet('config set environmentpath \$confdir/environments'))
      # need to restart the server to make this change take effect.
      # TODO: should move the restart into a helper method or something, this
      # is duplicated in 99_restart_server.rb.
      service_name = get_puppet_server_service_name_from_env()

      on(host, "systemctl restart #{service_name}")

      Beaker::Log.notify("Finished restarting service #{service_name}")

      # now update the value for environments dir
      environments = on(host, puppet('config print environmentpath')).stdout.chomp
    end
    manifestdir = "#{environments}/production/manifests"
    manifestfile = "#{manifestdir}/site.pp"
    Beaker::Log.notify("Saving node configs for env 'production' to file '#{manifestfile}'")
    sitepp = generate_sitepp()

    on(host, "mkdir -p #{manifestdir}")
    create_remote_file(host, manifestfile, sitepp)
    on(host, "chmod 644 #{manifestfile}")
    on(host, "cat #{manifestfile}")
  end

  def configure_gatling_auth
    # Make room for local copies
    ssldir = 'simulation-runner/target/ssl'
    FileUtils.rm_rf(ssldir)
    FileUtils.mkdir_p(ssldir)

    # Copy over master's cert
    mastercert = on(master, puppet('config print hostcert')).stdout.chomp
    scp_from(master, mastercert, ssldir)
    FileUtils.mv(File.join(ssldir, File.basename(mastercert)),
                 File.join(ssldir, 'mastercert.pem'))

    # Copy over master's private key
    masterkey = on(master, puppet('config print hostprivkey')).stdout.chomp
    scp_from(master, masterkey, ssldir)
    FileUtils.mv(File.join(ssldir, File.basename(masterkey)),
                 File.join(ssldir, 'masterkey.pem'))

    # Copy over CA's cert
    cacert = on(master, puppet('config print localcacert')).stdout.chomp
    scp_from(master, cacert, ssldir)
    FileUtils.mv(File.join(ssldir, File.basename(cacert)),
                 File.join(ssldir, 'cacert.pem'))

    # Generate keystore
    # Keystore is created on the test runner and requires that the following
    # executables be available:
    #   openssl
    #   keytool
    master_certname = on(master, puppet('config print certname')).stdout.chomp
    %x{cat #{ssldir}/mastercert.pem #{ssldir}/masterkey.pem > #{ssldir}/keystore.pem}
    fail_test('Failed to create keystore.pem') unless $?.success?
    %x{echo "puppet" | openssl pkcs12 -export -in #{ssldir}/keystore.pem -out #{ssldir}/keystore.p12 -name #{master_certname} -passout fd:0}
    fail_test('Failed to create keystore.p12') unless $?.success?
    %x{keytool -importkeystore -destkeystore #{ssldir}/gatling-keystore.jks -srckeystore #{ssldir}/keystore.p12 -srcstoretype PKCS12 -alias #{master_certname} -deststorepass "puppet" -srcstorepass "puppet"}
    fail_test('Failed to create jks keystore') unless $?.success?

    # Generate truststore
    %x{keytool -import -alias "CA" -keystore #{ssldir}/gatling-truststore.jks -storepass "puppet" -trustcacerts -file #{ssldir}/cacert.pem -noprompt}
    fail_test('Failed to create jks truststore') unless $?.success?
  end

  def configure_permissive_server_auth
    step 'Configure permissive auth.conf on master' do

      auth_conf = '/etc/puppetlabs/puppetserver/conf.d/auth.conf'
      create_remote_file(master, auth_conf, <<-EOF)
authorization: {
    version: 1
    rules: [
        {
            match-request: {
                path: "/"
                type: path
            }
            allow-unauthenticated: true
            sort-order: 1
            name: "Puppet Gatling Load Test -- allow all"
        }
    ]
}
      EOF

    end
  end

  def install_deps
    step "Configure epel" do
      tmp_module_dir = master.tmpdir('configure_epel')
      on(master, puppet('module', 'install', 'stahnma-epel', '--codedir', tmp_module_dir))
      on(master, puppet('apply', '-e', "'include epel'", '--codedir', tmp_module_dir))
      on(master, "rm -rf #{tmp_module_dir}")
    end

    step "Install jq" do
      install_package master, 'jq'
    end
  end

  def setup_gatling_proxy
    step 'install java, xauth' do
      on metric, 'yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel xauth'
    end
    step 'install scala build tool (sbt)' do
      on metric, 'rpm -ivh http://dl.bintray.com/sbt/rpm/sbt-0.13.7.rpm'
    end
    step 'create key for metrics to talk to primary master' do
      on metric, 'yes | ssh-keygen -q -t rsa -b 4096 -f /root/.ssh/id_rsa -N "" -C "gatling"'
    end
    step 'put keys on the primary master' do
      results = on metric, 'cat /root/.ssh/id_rsa.pub'
      key = results.stdout.strip
      on master, "echo \"#{key}\" >> /root/.ssh/authorized_keys"
    end
    step 'setup target dirs and copy simulation-runner directory to metric host' do
      metric.mkdir_p "gatling-puppet-load-test/simulation-runner/target/ssl"
      metric.mkdir_p "gatling-puppet-load-test/simulation-runner/results"
      scp_to(metric, "simulation-runner", "gatling-puppet-load-test")
    end
    step 'copy ssl certs to metrics box' do
      scp_to(metric, 'simulation-runner/target/ssl', 'gatling-puppet-load-test/simulation-runner/target')
    end
    step 'adjust scala build tool mem' do
      metric.mkdir_p '/usr/share/sbt/conf/'
      on metric, "echo '-mem 3072' >> /usr/share/sbt/conf/sbtopts"
    end
    step 'Change default java version on amazon-6 OS for opsworks' do
      on metric, "/usr/sbin/alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java"
    end if metric['template'] == 'amazon-6-x86_64'
  end

  def setup_metrics_as_agent
    step 'setup proxy-recorder dir' do
      # Make room for local copies
      ssldir = 'proxy-recorder/target/tmp/ssl'
      FileUtils.rm_rf(ssldir)
      FileUtils.mkdir_p(ssldir)

      master_cert_name = on(master, puppet('config print certname')).stdout.chomp
      master_host_cert = on(master, puppet('config print hostcert')).stdout.chomp
      master_host_priv_key = on(master, puppet('config print hostprivkey')).stdout.chomp

      scp_from(master, master_host_cert, ssldir)
      FileUtils.mv(File.join(ssldir, File.basename(master_host_cert)),
                   File.join(ssldir, 'hostcert.pem'))
      scp_from(master, master_host_priv_key, ssldir)
      FileUtils.mv(File.join(ssldir, File.basename(master_host_priv_key)),
                   File.join(ssldir, 'hostkey.pem'))

      # Keystore is created on the test runner and requires that the following
      # executables be available:
      #   openssl
      #   keytool
      %x{cat #{ssldir}/hostcert.pem #{ssldir}/hostkey.pem > #{ssldir}/keystore.pem}
      fail_test('Failed to create keystore.pem') unless $?.success?
      %x{echo "puppet" | openssl pkcs12 -export -in #{ssldir}/keystore.pem -out #{ssldir}/keystore.p12 -name #{master_cert_name} -passout fd:0}
      fail_test('Failed to create keystore.p12') unless $?.success?
      %x{keytool -importkeystore -destkeystore #{ssldir}/gatling-proxy-keystore.jks -srckeystore #{ssldir}/keystore.p12 -srcstoretype PKCS12 -alias #{master_cert_name} -deststorepass "puppet" -srcstorepass "puppet"}
      fail_test('Failed to create jks keystore') unless $?.success?

      metric.mkdir_p "gatling-puppet-load-test/proxy-recorder"
      scp_to(metric, "proxy-recorder", "gatling-puppet-load-test")

      classify_metrics_node_via_nc
    end
  end



  def classify_metrics_node_via_nc
    metrics_cert_name = on(metric, puppet('config print certname')).stdout.chomp
    # get classifier and set timeout
    classifier = get_classifier
    classifier.find_or_create_node_group_model(
        'parent' => '00000000-0000-4000-8000-000000000000',
        'name' => 'perf-agent-group',
        'rule' => [ 'or',
                    ['~', ['fact', 'clientcert'], metrics_cert_name],
                    ['~', ['fact', 'clientcert'], '.*agent.*'] ] )
  end

  def classify_master_node_via_nc
    master_cert_name = on(master, puppet('config print certname')).stdout.chomp
    # get classifier and set timeout
    classifier = get_classifier
    classifier.find_or_create_node_group_model(
        'parent' => '00000000-0000-4000-8000-000000000000',
        'name' => 'master-group',
        'rule' => [ '~', ['fact', 'clientcert'], master_cert_name],
        'classes' => { 'role::puppet_master' => nil } )
  end
end
