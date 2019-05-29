# frozen_string_literal: true

# rubocop:disable Style/SpecialGlobalVars

require "open-uri"
require "scooter"
require "tmpdir"
require "yaml"
require "beaker"
require "net/http"
require "beaker-pe" # PE-25240 will make this not needed

# PerfHelper
module PerfHelper
  BASE_URL = "http://builds.puppetlabs.lan"
  R10K_DIR = "/opt/puppetlabs/scratch/perf_testing/r10k"
  R10K_CONFIG_PATH = "#{R10K_DIR}/r10k.yaml"

  def set_etc_hosts
    puppet_ip = any_hosts_as?(:loadbalancer) ? loadbalancer.ip : master.ip
    on hosts, "echo '#{puppet_ip} puppet' >> /etc/hosts"
  end

  def install_epel_packages
    # Yum returns 1 if a package is already installed and we try to install
    # it, so just always return true when adding a repo or installing a
    # package for the metrics stuff.

    step "add epel" do
      # Graphite / grafana needs a newer version of python which is only found
      # in the epel repo.
      # Also needed for newer version of atop
      hosts.each do |host|
        platform_ver = host["platform"].version
        fedora_ep = "https://dl.fedoraproject.org/pub/epel"
        epel_url = "#{fedora_ep}/epel-release-latest-#{platform_ver}.noarch.rpm"
        host.install_package(epel_url, "", nil, acceptable_exit_codes: [0, 1])
      end
    end

    step "disable selinux on metrics server" do
      # disable selinux immediately, but not persistent after a reboot
      on agents, "setenforce 0 || true"
      # required to disable selinux between reboots
      sed_cmd = "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' "\
                "/etc/sysconfig/selinux "\
                "&& cat /etc/sysconfig/selinux"
      on agents, sed_cmd unless
          # FIXME: What is `agents[0]` intended to be?
          agents[0]["template"] == "amazon-6-x86_64"
    end

    step "install nc for agents to report run times to graphite" do
      on agents, "yum install -y nc || true"
    end

    step "ensure iptables chkconfig is disabled on el6" do
      hosts.each do |host|
        on host, "chkconfig iptables off" if host["platform"] == "el-6-x86_64"
      end
    end
  end

  def setup_r10k
    # Get all hosts with role master or compile_master
    masters = select_hosts(roles: %w[master compile_master])

    step "install git on masters for file syncing" do
      # vcloud VM's do not have git installed
      masters.each do |node|
        install_package node, "git"
      end
    end
  end

  # rubocop:disable Security/Open
  def download_file(url, destination)
    raise "Specified URL does not exist: #{url}" unless link_exists?(url)

    puts "Downloading #{url} to #{destination}"
    IO.copy_stream(open(URI(url)), destination)
    raise "Download was not successful" unless File.exist?(destination)
  end
  # rubocop:enable Security/Open

  def perf_install_pe
    unless is_pre_aio_version?
      # Must include the dashboard so that split installs add these answers
      # to classification
      r10k_remote = "/opt/puppetlabs/server/data/puppetserver/r10k/control-repo"
      @options[:answers] ||= {}
      @options[:answers][
        "puppet_enterprise::profile::master::r10k_remote"] = r10k_remote
      @options[:answers][
        "puppet_enterprise::profile::puppetdb::node_ttl"] = "0s"
    end

    step "install PE" do
      install_lei
    end
  end

  def cent7_repo?(package, version)
    cent7_uri = URI([BASE_URL,
                     package,
                     version,
                     "repo_configs",
                     "rpm",
                     "pl-#{package}-#{version}-el-7-x86_64.repo"].join("/"))

    response_code = Net::HTTP.start(cent7_uri.host, cent7_uri.port) do |http|
      http.head(cent7_uri.path).code
    end

    if response_code != "200"
      Beaker::Log.notify("Skipping #{package} version #{version} because it "\
                         "doesn't appear to have a cent7 repo")
      false
    else
      Beaker::Log.notify("Found Cent7 repo for #{package} version #{version}")
      true
    end
  end

  def cent7_repo(response_lines, package)
    response_lines
      .map { |l| l.match(%r{^.*href="([^"]+)\/\?C=M&amp;O=D".*$})[1] }
      .find { |v| cent7_repo?(package, v) }
  end

  def latest_server_version(version)
    response = Net::HTTP.get(URI(BASE_URL + "/puppetserver/?C=M&O=D"))

    # Scrape the puppetserver repo page for available puppetserver builds and
    # filter down to only ones matching the specified branch.  The list of
    # builds is ordered from most recent to oldest.  The resulting list is
    # passed along to the cent7_repo routine, which returns a URL for the
    # first build which has a cent7 repo in it.
    cent7_repo(
      response.lines
        .select { |l| l =~ /<td><a / }
        .select { |l| l =~ %r{">.*#{version}.*\/<\/a>} }, "puppetserver"
    )
  end

  def latest_agent_version
    url = "http://builds.delivery.puppetlabs.net/passing-agent-SHAs/api/v1/json/report-master"

    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)

    if response.code == "200"
      json = JSON.parse(response.body)
      json["suite-commit"].strip
    else
      Beaker::Log.notify("Unable to get last successful build from: #{url}, "\
                         "error: #{response.code}, #{response.message}")
      nil
    end
  end

  def latest_release_agent_version
    response = Net::HTTP.get(URI(BASE_URL + "/puppet-agent/?C=M&O=D"))

    # Scrape the puppet-agent repo page for available puppet-agent builds and
    # filter down to only released builds (e.g., 1.2.3) vs.  some mergely/SHA
    # version.  The list of builds is ordered from most recent to oldest.  The
    # resulting list is passed along to the cent7_repo routine, which
    # returns a URL for the first build which has a cent7 repo in it.
    href_pat = %r{^.*href="(\d+\.\d+\.\d+)\/\?C=M&amp;O=D".*$}
    cent7_repo(
      response.lines
        .select { |l| l =~ /<td><a / }
        .select { |l| l.match(href_pat) },
      "puppet-agent"
    )
  end

  def perf_install_foss
    install_opts = options.merge(dev_builds_repos: ["PC1"])
    repo_config_dir = "tmp/repo_configs"

    step "Setup Puppet repositories" do
      puppet_agent_version = ENV["PUPPET_AGENT_VERSION"]

      case puppet_agent_version
      when "latest"
        puppet_agent_version = latest_agent_version
      when "latest-release"
        puppet_agent_version = latest_release_agent_version
      end

      if puppet_agent_version
        Beaker::Log.notify("Installing OSS Puppet AGENT version "\
                           "'#{puppet_agent_version}'")
        install_puppetlabs_dev_repo master, "puppet-agent",
                                    puppet_agent_version,
                                    repo_config_dir, install_opts
        install_puppetlabs_dev_repo agent, "puppet-agent",
                                    puppet_agent_version,
                                    repo_config_dir, install_opts
      else
        abort("Environment variable PUPPET_AGENT_VERSION required for "\
              "package installs!")
      end
    end

    step "Setup Puppet Server repositories." do
      package_build_version = ENV["PACKAGE_BUILD_VERSION"]

      if package_build_version == "latest"
        Beaker::Log.notify("Looking for the very latest Puppet Server build")
        package_build_version = "master"
      end

      if package_build_version =~ /SNAPSHOT$/ ||
         package_build_version == "master"
        package_build_version = latest_server_version(package_build_version)
      end

      if package_build_version
        Beaker::Log.notify("Installing OSS Puppet Server version "\
                           "'#{package_build_version}'")
        install_puppetlabs_dev_repo master, "puppetserver",
                                    package_build_version,
                                    repo_config_dir, install_opts
      else
        abort("Environment variable PACKAGE_BUILD_VERSION required for "\
              "package installs!")
      end
    end

    step "Upgrade nss to be compatible with puppetserver jdk." do
      nss_package_name = nil
      variant, = master["platform"].to_array
      case variant
      when /^(debian|ubuntu)$/
        nss_package_name = "libnss3"
      when /^(redhat|el|centos)$/
        nss_package_name = "nss"
      end
      if nss_package_name
        master.upgrade_package(nss_package_name)
      else
        Beaker::Log.warn("Don't know what nss package to use for #{variant} "\
                         "so not installing one")
      end
    end

    step "Install Puppet Server." do
      install_package master, "puppetserver"
      on(master, "puppet config set --section master autosign true")
      on(master, "service puppetserver start")
      on(master, "puppet agent -t --server #{master}")
    end

    step "Install Puppet Agent." do
      install_package agent, "puppet-agent"
      on(agent, "puppet agent -t --server #{master}")
      on(master, "puppet config delete --section master autosign")
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
    r10k_config_contents = <<~R10KCONF
      :cachedir: '#{cachedir}'
      :sources:
        :perf-test:
          remote: '#{r10k_config[:control_repo]}'
          basedir: '#{r10k_config[:basedir]}'
    R10KCONF

    create_remote_file(host, R10K_CONFIG_PATH, r10k_config_contents)
  end

  def run_r10k_deploy(host, bin, environments, exec_options)
    r10k = "#{bin}/r10k"
    results = {}
    environments.each do |env|
      result = on(host, "#{r10k} deploy environment \
                         #{env} -p -v debug -c #{R10K_CONFIG_PATH}",
                  exec_options)
      results[env] = result.exit_code
    end
    results
  end

  def r10k_deploy
    bin = ENV['PUPPET_BIN_DIR']
    r10k_version = ENV['PUPPET_R10K_VERSION'] || '3.2.0'

    step "Install and configure r10k" do
      r10k_config = get_r10k_config_from_env
      raise "No R10K config found in environment!" unless r10k_config

      install_r10k(master, bin, r10k_version)
      create_r10k_config(master, r10k_config)

      # This is straight up horrific.  Sorry.
      # Old versions of r10k can do fun things like throw NPEs and return a
      # non-zero exit code even when they've actually successfully deployed.
      # If you then simply re-run the same r10k command afterward, it'll get
      # a zero exit code.  So, we will do an initial deploy and then if we
      # got any non-zero exit codes, we'll try those environments one more
      # time.
      results = run_r10k_deploy(master, bin, r10k_config[:environments],
                                acceptable_exit_codes: [0, 1])
      failed_envs = results.select { |_env, exit_code| exit_code == 1 }.keys
      if failed_envs.size.positive?
        Beaker::Log.warn("R10K deploy failed on environments: \
                          #{failed_envs}; trying one more time.")
        run_r10k_deploy(master, bin, failed_envs, {})
      end
    end

    puppet_module_dependencies
  end

  def puppet_module_dependencies
    # Hacky, but new versions of puppet require different stuff in Puppetfile,
    # for older versions, remove those lines.
    step "Use external puppet modules for puppet >= 6.0" do
      staging_prod = "/etc/puppetlabs/code-staging/environments/production"
      staging_prod.freeze
      puppet_version = on(master, "puppet --version").stdout
      if master.version_is_less(puppet_version, "6.0")
        on master, "sed -i '/puppetlabs\\/.*_core/d' #{staging_prod}/Puppetfile"
        on master, "rm -rf #{staging_prod}/modules/*_core"
      end
    end
  end

  def enable_file_sync
    api = Scooter::HttpDispatchers::ConsoleDispatcher.new(dashboard)
    pe_master_group = api.get_node_group_by_name("PE Master")
    pe_master_group["classes"]["puppet_enterprise::profile::master"][
      "file_sync_enabled"] = true
    api.replace_node_group(pe_master_group["id"], pe_master_group)
    on(master, "puppet agent -t", acceptable_exit_codes: [0, 2])
  end

  # Commit and force-sync file sync
  #
  # This method hits the file sync 'force sync' endpoint, which will hopefully
  # trigger a synchronous sync of the files.  Ideally that means that when
  # this curl command returns, we know that the sync is complete and that the
  # files have been deployed successfully.
  def sync_code_dir
    fs_commands = { 'commit': '{"commit-all": true}', 'force-sync': "" }
    fs_commands.each do |fs_cmd, data|
      curl = %W[
        curl
        -X POST
        --cert $(puppet config print hostcert)
        --key $(puppet config print hostprivkey)
        --cacert $(puppet config print localcacert)
        -H "Content-type: application/json"
        https://#{master}:8140/file-sync/v1/#{fs_cmd}
        -d '#{data}'
      ].join(" ")

      on(master, curl)
    end
  end

  def classifier
    @classifier ||= Scooter::HttpDispatchers::ConsoleDispatcher.new(dashboard)
    # Updating classes can take a VERY long time, like the OPS deployment
    # which has ~80 environments each with hundreds of classes.
    # Set the connection timeout to 60 minutes to accomodate this.
    @classifier.connection.options.timeout = 3600
    @classifier.update_classes
    @classifier
  end

  def classify_nodes_via_nc
    # Classify any agent with the word 'agent' in it's hostname.
    # get classifier and set timeout
    classifier.find_or_create_node_group_model(
      "parent"  => "00000000-0000-4000-8000-000000000000",
      "name"    => "perf-agent-group",
      "rule"    => ["~", %w[fact clientcert], ".*agent.*"],
      "classes" => { ENV["PUPPET_SCALE_CLASS"] => nil }
    )
  end

  def generate_sitepp
    <<~SITEPP
      node /.*agent.*/ { include #{ENV['PUPPET_SCALE_CLASS']} }
      node 'default' {}
    SITEPP
  end

  def classify_foss_nodes(host)
    environments = puppet_config(host, "environmentpath")
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
      service_name = get_puppet_server_service_name_from_env

      on(host, "systemctl restart #{service_name}")

      Beaker::Log.notify("Finished restarting service #{service_name}")

      # now update the value for environments dir
      environments = puppet_config(host, "environmentpath")
    end
    manifestdir = "#{environments}/production/manifests"
    manifestfile = "#{manifestdir}/site.pp"
    Beaker::Log.notify("Saving node configs for env 'production' to file "\
                       "'#{manifestfile}'")
    sitepp = generate_sitepp

    on(host, "mkdir -p #{manifestdir}")
    create_remote_file(host, manifestfile, sitepp)
    on(host, "chmod 644 #{manifestfile}")
    on(host, "cat #{manifestfile}")
  end

  # Get the `puppet config print` value
  #
  # @param [Beaker::Host] host
  # @param [String] config
  # @returns [String]
  def puppet_config(host, config)
    on(host, puppet("config print #{config}")).stdout.chomp
  end

  def configure_gatling_auth
    # Make room for local copies
    ssldir = "simulation-runner/target/ssl"
    FileUtils.rm_rf(ssldir)
    FileUtils.mkdir_p(ssldir)

    # Copy over master's cert
    mastercert = puppet_config(master, "hostcert")
    scp_from(master, mastercert, ssldir)
    FileUtils.mv(File.join(ssldir, File.basename(mastercert)),
                 File.join(ssldir, "mastercert.pem"))

    # Copy over master's private key
    masterkey = puppet_config(master, "hostprivkey")
    scp_from(master, masterkey, ssldir)
    FileUtils.mv(File.join(ssldir, File.basename(masterkey)),
                 File.join(ssldir, "masterkey.pem"))

    # Copy over CA's cert
    cacert = puppet_config(master, "localcacert")
    scp_from(master, cacert, ssldir)
    FileUtils.mv(File.join(ssldir, File.basename(cacert)),
                 File.join(ssldir, "cacert.pem"))

    # Generate keystore
    # Keystore is created on the test runner and requires that the following
    # executables be available:
    #   openssl
    #   keytool
    master_certname = puppet_config(master, "certname")
    `cat #{ssldir}/mastercert.pem \
         #{ssldir}/masterkey.pem > #{ssldir}/keystore.pem`
    fail_test("Failed to create keystore.pem") unless $?.success?
    `echo "puppet" | openssl pkcs12 \
                             -export \
                             -in #{ssldir}/keystore.pem \
                             -out #{ssldir}/keystore.p12 \
                             -name #{master_certname} \
                             -passout fd:0`
    fail_test("Failed to create keystore.p12") unless $?.success?
    `keytool -importkeystore \
             -destkeystore #{ssldir}/gatling-keystore.jks \
             -srckeystore #{ssldir}/keystore.p12 \
             -srcstoretype PKCS12 \
             -alias #{master_certname} \
             -deststorepass "puppet" \
             -srcstorepass "puppet"`
    fail_test("Failed to create jks keystore") unless $?.success?

    # Generate truststore
    `keytool -import \
             -alias "CA" \
             -keystore #{ssldir}/gatling-truststore.jks \
             -storepass "puppet" \
             -trustcacerts \
             -file #{ssldir}/cacert.pem -noprompt`
    fail_test("Failed to create jks truststore") unless $?.success?
  end

  def configure_permissive_server_auth
    step "Configure permissive auth.conf on master" do
      auth_conf = "/etc/puppetlabs/puppetserver/conf.d/auth.conf"
      create_remote_file(master, auth_conf, <<~AUTHCONF)
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
      AUTHCONF
    end
  end

  def install_deps
    step "Configure epel" do
      tmp_module_dir = master.tmpdir("configure_epel")
      on(master, puppet("module", "install",
                        "stahnma-epel", "--codedir", tmp_module_dir))
      on(master, puppet("apply", "-e",
                        "'include epel'", "--codedir", tmp_module_dir))
      on(master, "rm -rf #{tmp_module_dir}")
    end
    step "Install jq" do
      install_package master, "jq"
    end
  end

  def setup_gatling_proxy
    # TODO: This should be wrapped into a puppet module and applied to the
    # metric node
    step "install java, xauth" do
      on metric, 'yum -y install \
                         java-1.8.0-openjdk java-1.8.0-openjdk-devel xauth'
    end
    step 'install scala build tool (sbt)' do
      on metric, 'yum localinstall -y http://dl.bintray.com/sbt/rpm/sbt-0.13.7.rpm'
    end
    step "create key for metrics to talk to primary master" do
      on metric, 'yes | ssh-keygen -q -t rsa -b 4096 \
                                   -f /root/.ssh/id_rsa -N "" -C "gatling"'
    end
    step "put keys on the primary master" do
      results = on metric, "cat /root/.ssh/id_rsa.pub"
      key = results.stdout.strip
      on master, "echo \"#{key}\" >> /root/.ssh/authorized_keys"
    end
    step "setup target dirs/copy simulation-runner directory to metric host" do
      metric.mkdir_p "gatling-puppet-load-test/simulation-runner/target/ssl"
      metric.mkdir_p "gatling-puppet-load-test/simulation-runner/results"
      scp_to(metric, "simulation-runner", "gatling-puppet-load-test")
    end
    step "copy ssl certs to metrics box" do
      scp_to(metric, "simulation-runner/target/ssl",
             "gatling-puppet-load-test/simulation-runner/target")
    end
    step "adjust scala build tool mem" do
      metric.mkdir_p "/usr/share/sbt/conf/"
      on metric, "echo '-mem 3072' >> /usr/share/sbt/conf/sbtopts"
    end
    step "Change default java version on amazon-6 OS for opsworks" do
      on metric, '/usr/sbin/alternatives \
                     --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java'
    end if metric["template"] == "amazon-6-x86_64"
  end

  def setup_metrics_as_agent
    step "setup proxy-recorder dir" do
      # Make room for local copies
      ssldir = "proxy-recorder/target/tmp/ssl"
      FileUtils.rm_rf(ssldir)
      FileUtils.mkdir_p(ssldir)

      master_cert_name = puppet_config(master, "certname")
      master_host_cert = puppet_config(master, "hostcert")
      master_host_priv_key = puppet_config(master, "hostprivkey")

      scp_from(master, master_host_cert, ssldir)
      FileUtils.mv(File.join(ssldir, File.basename(master_host_cert)),
                   File.join(ssldir, "hostcert.pem"))
      scp_from(master, master_host_priv_key, ssldir)
      FileUtils.mv(File.join(ssldir, File.basename(master_host_priv_key)),
                   File.join(ssldir, "hostkey.pem"))

      # Keystore is created on the test runner and requires that the following
      # executables be available:
      #   openssl
      #   keytool
      `cat #{ssldir}/hostcert.pem \
           #{ssldir}/hostkey.pem > #{ssldir}/keystore.pem`
      fail_test("Failed to create keystore.pem") unless $?.success?
      `echo "puppet" | openssl pkcs12 \
                               -export -in #{ssldir}/keystore.pem \
                               -out #{ssldir}/keystore.p12 \
                               -name #{master_cert_name} \
                               -passout fd:0`
      fail_test("Failed to create keystore.p12") unless $?.success?
      `keytool -importkeystore \
               -destkeystore #{ssldir}/gatling-proxy-keystore.jks \
               -srckeystore #{ssldir}/keystore.p12 \
               -srcstoretype PKCS12 \
               -alias #{master_cert_name} \
               -deststorepass "puppet" \
               -srcstorepass "puppet"`
      fail_test("Failed to create jks keystore") unless $?.success?

      metric.mkdir_p "gatling-puppet-load-test/proxy-recorder"
      scp_to(metric, "proxy-recorder", "gatling-puppet-load-test")

      classify_metrics_node_via_nc
    end
  end

  def classify_metrics_node_via_nc
    metrics_cert_name = puppet_config(metric, "certname")
    # get classifier and set timeout
    classifier.find_or_create_node_group_model(
      "parent" => "00000000-0000-4000-8000-000000000000",
      "name"   => "perf-agent-group",
      "rule"   => ["or",
                   ["~", %w[fact clientcert], metrics_cert_name],
                   ["~", %w[fact clientcert], ".*agent.*"]]
    )
  end

  def classify_master_node_via_nc
    master_cert_name = puppet_config(master, "certname")
    # get classifier and set timeout
    classifier.find_or_create_node_group_model(
      "parent"  => "00000000-0000-4000-8000-000000000000",
      "name"    => "master-group",
      "rule"    => ["~", %w[fact clientcert], master_cert_name],
      "classes" => { "role::puppet_master" => nil }
    )
  end

  def setup_puppet_metrics_collector_for_foss
    custom_fact_content = 'pe_server_version=""'
    custom_fact_path = '/opt/puppetlabs/facter/facts.d/custom.txt'
    create_remote_file(master, custom_fact_path, custom_fact_content)
    on(master, 'puppet apply -e "include puppet_metrics_collector"', :acceptable_exit_codes => [0,2])
  end

  def setup_puppet_metrics_collector_for_foss
    custom_fact_content = 'pe_server_version=""'
    custom_fact_path = '/opt/puppetlabs/facter/facts.d/custom.txt'
    create_remote_file(master, custom_fact_path, custom_fact_content)
    on(master, 'puppet apply -e "include puppet_metrics_collector"', :acceptable_exit_codes => [0,2])
  end
end
# rubocop:enable Style/SpecialGlobalVars
