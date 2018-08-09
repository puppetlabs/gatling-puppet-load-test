require 'scooter'
require 'tmpdir'
require 'yaml'
require 'beaker'
require 'net/http'

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
      on agents, "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux"
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

    step 'place private key on each master' do
      #public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCYh3jLwtuf1Ef/w/FZWqpsl4QS7RA4mkmeyIrbH8LQpAVAWBdLmU+x7vC0W1K47RgNjIVAGmiPwGY1MGc2ZakoFJWVLelq4ew8GiUODYOn7PAW531j6BmNNEJvWsNgfDw6EOj2r0VqOr+k3mttAG7NI1MfLlstIPJk/Ua13gPkKjUqK1GvZnf7lHXFqOMH31fZ1FPMUTqoLo5okMJ/l9axgBL08ibPdPoeJPa0xy2VHFdX9Ud9UnFblbIi6nlCngpfKJKeyiDURt6vUuFmEwrhumyWY75xRaXrif59FyXXtOBBPq8WAqTBkVjMUEyiWt/+j7nnbgwLsKGFcLPKhG/J deploykey@puppet-scale-control"
      private_key = <<-PRIVATE_KEY
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAmId4y8Lbn9RH/8PxWVqqbJeEEu0QOJpJnsiK2x/C0KQFQFgX
S5lPse7wtFtSuO0YDYyFQBpoj8BmNTBnNmWpKBSVlS3pauHsPBolDg2Dp+zwFud9
Y+gZjTRCb1rDYHw8OhDo9q9Fajq/pN5rbQBuzSNTHy5bLSDyZP1Gtd4D5Co1KitR
r2Z3+5R1xajjB99X2dRTzFE6qC6OaJDCf5fWsYAS9PImz3T6HiT2tMctlRxXV/VH
fVJxW5WyIup5Qp4KXyiSnsog1Eber1LhZhMK4bpslmO+cUWl64n+fRcl17TgQT6v
FgKkwZFYzFBMolrf/o+5524MC7ChhXCzyoRvyQIDAQABAoIBAAakb6g/9hyBvBjx
SYNgpWdROdkxJbGxVl9p0FI2kd9QJUJmE62hIY1YIHdaOsH+4TtF0U+3VrJb6JeM
YhJGXxV1wAXdF/sll4oOgWqZQBCCCvqUXiuJogM6MWJ0C2oaPu0wa1TC0T0NDed6
ICeBC1I3pZkIBcRzWNr5BKlK39SByNOMPoBLVBlf4oNUKSYWTJRwYajLae6z7czs
64Tj2G0llsgeDFkqyXmbbditJpktZPSY4bo5tmoxPGMsFfZMjpqPmCo+d++NLktJ
ZOISWsan8unhJQdGbnRlMB6JauXs1LWjYVIBuh6TtwbVqf9WpqVA+dL0mUVcPdxA
4SemxOECgYEAyqvS/DOLjrw9X0ajR3oHd1/GBPnnVbvetPbmGaVKkeUmqugWJ/R3
FQHUR1TiEq+ycxEp35Xmu9JNgSU5lpdl3FppTlA99pOiV6AcrCXRZf1Y7jiFyn/x
c6Q9MX13VanA+Qtbs5VTwXXuIFWl0EUVdi8SRfKJO2aFnRk5ZJxkVaUCgYEAwKoF
oJpeMdccnUtLh55luGerz1gl1mGmdAIEUYDW7YWqUjCqFM/yWx5jCFihLbQUfJXs
YsgTkU54k593BIpX2iPD3bS/RvRMdRPnb/Y70822NTAdjrmVs17VRqeU66+ua2Je
gE/LCrxQX+G0Ryw8zb5NRx0Kd9jg0RIXm+okAFUCgYEAr7rGiSlEc7HiYQ9Fmj9D
5AzmDQCGxn7Mfwqpv0jj3JbdrUjplSFSc6OPZX5DO8KeL0mNjjFSzD5wN2+IfHuv
tZ2rO102LOwb0nChC98Krq06g+v8jfXb7NJWwOeyJlO3X/mqPI9Y/SD9JYo96NVN
45iy9nVy6k9dwTbS3dsA4IUCgYAk2B7tYLgExgN13TFbhSIkysajh1LtFY2Uf9I9
l+sCT16MCzxrcH0DieMcdH6WU+rbDHzBQ0virOQILyW+m4pDcDWDz44Izq1UcnL/
CVLVpXBj6Yitg7YqMEePFHs5O0aayJwT466Lpgmk3G/ycHZMTklPATHAS5xqvw/+
xB8QZQKBgQCfx99/nY0DDRcKkz4ftKEQC7wCligcMeYvPvsyfEs/Sm4dmWXXwUmM
rvUWLYk1rsTvRhcCl2X9mV7kQhV5jy+rhI/0Xlt9q7YD+/eoE0+xrxsFdvClBfr/
B5mRrDUW3rwnPdxJ3eONw5l4AistswtRPc45jHSbEfRXJQZIlIxB6A==
-----END RSA PRIVATE KEY-----
      PRIVATE_KEY

      ssh_config = <<SSH_CONFIG
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
SSH_CONFIG

      masters.each do |node|
        create_remote_file(node, "/root/.ssh/id_rsa", private_key)
        create_remote_file(node, "/root/.ssh/config", ssh_config)
        on node, "chmod 600 /root/.ssh/id_rsa /root/.ssh/config"
      end
    end

    step 'install git on masters for file syncing' do
      # vcloud VM's do not have git installed
      masters.each do |node|
        install_package node, 'git'
      end
    end
  end

  def perf_install_pe
    if !is_pre_aio_version?
      # Must include the dashboard so that split installs add these answers to classification
      r10k_remote = '/opt/puppetlabs/server/data/puppetserver/r10k/control-repo'
      r10k_private_key = '/root/.ssh/id_rsa'
      @options[:answers] ||= {}
      @options[:answers]['puppet_enterprise::profile::master::r10k_remote'] = r10k_remote
      @options[:answers]['puppet_enterprise::profile::master::r10k_private_key'] = r10k_private_key
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
  ##      comes in the control repository, like a hiera.yaml config file.
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
    ########################
    bin = ENV['PUPPET_BIN_DIR']
    r10k_version = ENV['PUPPET_R10K_VERSION']

    step "Install git" do
      on(master, puppet_resource("package git ensure=installed"))
    end

    step "Set up SSH key for github access" do
      if !master.file_exist?("/root/.ssh/id_rsa")
        result = curl_on master, "-o /root/.ssh/id_rsa 'http://int-resources.ops.puppetlabs.net/QE%20Shared%20Resources/gatling_test_keys/id_rsa'"
        assert_equal 0, result.exit_code

        on(master, "chmod 600 /root/.ssh/id_rsa")

        result = curl_on master, "-o /root/.ssh/id_rsa.pub 'http://int-resources.ops.puppetlabs.net/QE%20Shared%20Resources/gatling_test_keys/id_rsa.pub'"
        assert_equal 0, result.exit_code
      end
    end

    step "add github to known hosts" do
      # Create known_hosts file with GitHub host key to prevent
      # "Host key verification failed" errors during clones
      create_remote_file(master, "/root/.ssh/known_hosts", <<-EOS)
  github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
      EOS
    end

    step "install and configure r10k" do
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

  def classify_nodes_via_nc
    # Classify any agent with the word 'agent' in it's hostname.
    def classify_nodes(classifier)
      classifier.find_or_create_node_group_model(
          'parent' => '00000000-0000-4000-8000-000000000000',
          'name' => 'perf-agent-group',
          'rule' => ['~', ['fact', 'clientcert'], '.*agent.*'],
          'classes' => { ENV['PUPPET_SCALE_CLASS'] => nil } )
    end

    classifier = Scooter::HttpDispatchers::ConsoleDispatcher.new(dashboard, {:login => 'admin', :password => 'puppetlabs', :resolve_dns => true})

    # Updating classes can take a VERY long time, like the OPS deployment
    # which has ~80 environments each with hundreds of classes.
    # Set the connection timeout to 60 minutes to accomodate this.
    classifier.connection.options.timeout = 3600
    classifier.update_classes

    classify_nodes(classifier)
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

  def update_hiera_datadir_in_local_config
    config = YAML.load_file(@local_hiera_config_path)
    config[:yaml][:datadir] = '/etc/puppetlabs/code/environments/production/hieradata/'
    File.open(@local_hiera_config_path, 'w') { |f| f.write(config.to_yaml) }
  end

  def install_hiera_config(host)
    @source_hiera_config_path = '/etc/puppetlabs/code/environments/production/root_files/hiera.yaml'
    @target_hiera_config_path = on(master, puppet('config print hiera_config')).stdout.chomp
    local_hiera_dir = Dir.mktmpdir
    scp_from(master, @source_hiera_config_path, local_hiera_dir)
    @local_hiera_config_path = File.join(local_hiera_dir, 'hiera.yaml')
    update_hiera_datadir_in_local_config

    scp_to(host, @local_hiera_config_path, @target_hiera_config_path)
    on(host, "chmod 644 #{@target_hiera_config_path}")
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
    master_certname = on(master, puppet('config print certname')).stdout.chomp
    %x{cat #{ssldir}/mastercert.pem #{ssldir}/masterkey.pem > #{ssldir}/keystore.pem}
    %x{echo "puppet" | openssl pkcs12 -export -in #{ssldir}/keystore.pem -out #{ssldir}/keystore.p12 -name #{master_certname} -passout fd:0}
    %x{keytool -importkeystore -destkeystore #{ssldir}/gatling-keystore.jks -srckeystore #{ssldir}/keystore.p12 -srcstoretype PKCS12 -alias #{master_certname} -deststorepass "puppet" -srcstorepass "puppet"}

    # Generate truststore
    %x{keytool -import -alias "CA" -keystore #{ssldir}/gatling-truststore.jks -storepass "puppet" -trustcacerts -file #{ssldir}/cacert.pem -noprompt}
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
    step 'install rvm, bundler' do
      begin
        on metric, 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3'
      rescue
        # Execute alternative gpg command
        on metric, 'command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -'
      end

      on metric, 'curl -sSL https://get.rvm.io | bash -s stable'
      on metric, 'rvm install 2.4.2'
      on metric, 'gem install bundler'
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
  end

end
