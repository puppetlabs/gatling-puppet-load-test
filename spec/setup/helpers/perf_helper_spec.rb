require 'rspec'
require File.expand_path('../../../../setup/helpers/perf_helper', __FILE__)

class PerfHelperClass
  include PerfHelper
  # These are all attributes available in Beaker::TestCase that are accessed by our helper
  attr_accessor :hosts, :options, :agents


  def logger
    @logger = Beaker::Logger.new({:log_level => 'error'})
  end

  # Override the Beaker::TestCase step method since we execute all of our code within those blocks and can't just mock it out.
  # We also don't want to call the original because then we would have to also mock out a million other Beaker methods.
  def step(msg, &block)
    yield
  end

  def options
    @options = {}
  end


end

describe PerfHelperClass do
  let!(:hosts) {[{'platform' => Beaker::Platform.new('centos-6.5-x86_64')}]}

  context '.perf_init' do
    let!(:options) { {} }

    it 'it sets @install_opts to options with :dev_builds_repos option => ["PC1"]' do
      # TODO: test that @install_opts is set?
      allow(subject).to receive(:options).and_return(options)
      expect(subject.options).to receive(:merge).with({:dev_builds_repos => ["PC1"]})
      subject.perf_init
    end

  end

  context '.set_etc_hosts' do
    let!(:master) {[]}

    it 'it sets the puppet ip in /etc/hosts' do

      # TODO: is this the best way to handle loadbalancer.ip / master.ip
      master_ip = '127.0.0.1'
      allow(subject).to receive(:hosts).and_return(hosts)
      allow(master).to receive(:ip).and_return(master_ip)
      allow(subject).to receive(:master).and_return(master)

      # TODO: test both true and false (loadbalancer.ip / master.ip)?
      expect(subject).to receive(:any_hosts_as?).with((:loadbalancer)).and_return(false)
      expect(subject).to receive(:on).with(hosts, "echo \"#{master_ip} puppet\" >> /etc/hosts").once
      subject.set_etc_hosts

    end

  end

  context '.install_epel_packages' do

    it 'executes all commands to set up epel and packages' do
      allow(subject).to receive(:hosts).and_return(hosts)
      allow(subject).to receive(:agents).and_return(hosts)
      expect(subject.hosts[0]).to receive(:install_package).with("https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.5.noarch.rpm", '', nil, :acceptable_exit_codes => [0, 1])
      expect(subject).to receive(:on).with(hosts, 'setenforce 0 || true').once
      expect(subject).to receive(:on).with(hosts, "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux").once
      expect(subject).to receive(:on).with(hosts, 'yum install -y nc || true').once
      subject.install_epel_packages
    end

    it 'executes the el6 platform only command' do
      hosts[0]['platform'] = Beaker::Platform.new('el-6-x86_64')
      allow(subject).to receive(:hosts).and_return(hosts)
      allow(subject).to receive(:agents).and_return(hosts)
      expect(subject.hosts[0]).to receive(:install_package).with("https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm", '', nil, :acceptable_exit_codes => [0, 1])
      allow(subject).to receive(:on)
      expect(subject).to receive(:on).with(hosts[0], 'chkconfig iptables off').once
      subject.install_epel_packages
    end

  end

  context '.setup_r10k' do

    # TODO: is this the best way to handle masters?
    let!(:masters) {[{'platform' => Beaker::Platform.new('centos-6.5-x86_64')}]}

    it 'adds the private key, configures ssh, and installs git on each master' do

      allow(subject).to receive(:masters).and_return(masters)
      expect(subject).to receive(:select_hosts).with({:roles => ['master', 'compile_master']}).and_return(masters)

      # TODO: should these use the private_key and ssh_config variables or are these matchers sufficient?
      expect(subject).to receive(:create_remote_file).with(masters[0], "/root/.ssh/id_rsa", /PRIVATE/ )
      expect(subject).to receive(:create_remote_file).with(masters[0], "/root/.ssh/config", /StrictHostKeyChecking/ )

      expect(subject).to receive(:on).with(masters[0], "chmod 600 /root/.ssh/id_rsa /root/.ssh/config" )
      expect(subject).to receive(:install_package).with(masters[0], 'git')
      subject.setup_r10k

    end

  end

  describe '#cloud_config' do
    let(:host) {:hosts[0]}

    context 'when the cloud.cfg file exists' do
      it 'ensures preserve_hostname is set to true' do
        expect(host).to receive(:file_exist?).with(("/etc/cloud/cloud.cfg")).and_return(true)
        expect(subject).to receive(:on).with(host, "if grep 'preserve_hostname: true' /etc/cloud/cloud.cfg ; then echo 'already set' ; else echo 'preserve_hostname: true' >> /etc/cloud/cloud.cfg ; fi").once
        subject.cloud_config(host)
      end
    end

    context 'when the cloud.cfg file does not exist' do
      it 'does nothing' do
        expect(host).to receive(:file_exist?).with(("/etc/cloud/cloud.cfg")).and_return(false)
        expect(subject).to_not receive(:on)
        subject.cloud_config(host)
      end
    end

  end

  describe '#ec2_workarounds' do

    # TODO: refactor to avoid repeated steps

    context 'when the installer download is on the internal network' do
      let!(:master) { {'pe_dir' => 'puppetlabs.net'} }

      it 'runs cloud_config,then copies the file locally' do

        ENV['BEAKER_INSTALL_TYPE']='pe'

        allow(subject).to receive(:hosts).and_return(hosts)
        allow(subject).to receive(:master).and_return(master)

        expect(subject).to receive(:cloud_config).with(hosts[0])

        # TODO: verify curl_cmd?
        expect(subject).to receive(:system)

        subject.ec2_workarounds

      end
    end

    context 'when the installer download is not on the internal network' do
      let!(:master) { {'pe_dir' => 'other.net'} }

      it 'runs cloud_config, then does nothing' do

        # TODO: include additional test cases with alternate value?
        ENV['BEAKER_INSTALL_TYPE']='pe'

        allow(subject).to receive(:hosts).and_return(hosts)
        allow(subject).to receive(:master).and_return(master)

        expect(subject).to receive(:cloud_config).with(hosts[0])
        expect(subject).to_not receive(:system)

        subject.ec2_workarounds

      end
    end

  end


  context '.perf_install_pe' do

  end

  context '.has_cent7_repo?' do

  end

  context '.get_cent7_repo' do

  end

  context '.get_latest_server_version' do

  end

  context '.get_latest_agent_version' do

  end

  context '.get_latest_agent_version' do

  end

  context '.get_latest_release_agent_version' do

  end

  context '.install_puppet_agent_dev_repo_from_local_file' do

  end

  context '.install_repo_configs' do


  end

  context '.perf_install_foss' do

  end

  context '.install_r10k' do

  end

  context '.create_r10k_config' do

  end

  context '.run_r10k_deploy' do

  end

  context '.r10k_deploy' do

  end

  context '.enable_file_sync' do

  end

  context '.sync_code_dir' do

  end

  context '.classify_nodes_via_nc' do

  end

  context '.generate_sitepp' do

  end

  context '.classify_foss_nodes' do

  end

  context '.update_hiera_datadir_in_local_config' do

  end

  context '.install_hiera_config' do

  end

  context '.install_hiera_config' do

  end

  context '.use_internal_ips' do

  end

  context '.configure_gatling_auth' do

  end

  context '.configure_permissive_server_auth' do

  end

  context '.install_deps' do

      it 'sets the tmp_module_dir'

      it 'installs the jq package'

  end


  context '.setup_gatling_proxy' do

  end


end

