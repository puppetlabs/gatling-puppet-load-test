require 'rspec'
require File.expand_path('../../../../setup/helpers/perf_helper', __FILE__)

class PerfHelperClass
  include PerfHelper
  # These are all attributes available in Beaker::TestCase that are accessed by our helper
  attr_accessor :hosts, :options, :agents


  def logger
    @logger = Beaker::Logger.new({:log_level => 'error'})
  end



  # TODO???
  # def logger
  #   @log = Beaker::Log.new({:log_level => 'error'})
  # end
  #
  #

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

  context '.set_etc_hosts' do
    let!(:master) {[]}

    it 'it sets the puppet ip in /etc/hosts' do

      master_ip = '127.0.0.1'
      allow(subject).to receive(:hosts).and_return(hosts)
      allow(master).to receive(:ip).and_return(master_ip)
      allow(subject).to receive(:master).and_return(master)

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

    let!(:masters) {[{'platform' => Beaker::Platform.new('centos-6.5-x86_64')}]}

    it 'adds the private key, configures ssh, and installs git on each master' do

      allow(subject).to receive(:masters).and_return(masters)
      expect(subject).to receive(:select_hosts).with({:roles => ['master', 'compile_master']}).and_return(masters)

      expect(subject).to receive(:create_remote_file).with(masters[0], "/root/.ssh/id_rsa", /PRIVATE/ )
      expect(subject).to receive(:create_remote_file).with(masters[0], "/root/.ssh/config", /StrictHostKeyChecking/ )

      expect(subject).to receive(:on).with(masters[0], "chmod 600 /root/.ssh/id_rsa /root/.ssh/config" )
      expect(subject).to receive(:install_package).with(masters[0], 'git')
      subject.setup_r10k

    end

  end

  # TODO: refactor to remove duplication
  describe '#perf_install_pe' do

    context 'when pe is not a pre-aio version' do

      test_is_pre_aio_version = false

      context 'when we are using meep' do

        test_use_meep = true

        test_pe_ver = '2017.3'
        let!(:master) { {'pe_ver' => test_pe_ver} }

        # TODO: how should @options / @options[:answers] be handled?
        before {
          subject.instance_variable_set(:@options, { })
        }

        it 'includes the dashboard and installs pe' do

          expect(subject).to receive(:is_pre_aio_version?).and_return(test_is_pre_aio_version)
          expect(subject).to receive(:use_meep?).with(master['pe_ver'] || options['pe_ver']).and_return(test_use_meep)
          expect(subject).to receive(:master).and_return(master)

          # TODO: how to handle @options[:answers] ?
          expect(subject.instance_variable_get(:@options)). to eq({})

          expect(subject).to receive(:install_lei).once
          subject.perf_install_pe

        end

      end

      context 'when we are not using meep' do

        test_is_pre_aio_version = false
        test_use_meep = false

        test_boundary_version = '2016.2'

        context 'when version is less than 2016.2' do

          test_pe_ver = '2016.1'
          test_version_is_less = true

          let!(:master) { {'pe_ver' => test_pe_ver} }
          let!(:compile_masters) { {'pe_ver' => test_pe_ver} }
          let!(:dashboard) { {'pe_ver' => test_pe_ver} }

          it 'includes the dashboard and installs pe' do

            expect(subject).to receive(:is_pre_aio_version?).and_return(test_is_pre_aio_version)
            expect(subject).to receive(:use_meep?).with(master['pe_ver'] || options['pe_ver']).and_return(test_use_meep)

            # TODO: is allow acceptable here? expect error with '5 times'
            allow(subject).to receive(:master).and_return(master)

            expect(subject).to receive(:compile_masters).and_return(compile_masters)
            expect(subject).to receive(:dashboard).and_return(dashboard)

            # TODO: handle custom answers

            # TODO: handle pe_version master / options

            # TODO: version_is_less??
            expect(subject).to receive(:version_is_less).with(test_pe_ver, test_boundary_version).and_return(test_version_is_less)

            # TODO: pre_config_hiera - with?
            expect(subject).to receive(:pre_config_hiera)

            # TODO: master['hieradata_dir_used_in_install']

            expect(subject).to receive(:install_lei).once
            subject.perf_install_pe

          end

        end

        context 'when version is not less than 2016.2' do

          test_pe_ver = '2016.3'
          test_version_is_less = false

          let!(:master) { {'pe_ver' => test_pe_ver} }
          let!(:compile_masters) { {'pe_ver' => test_pe_ver} }
          let!(:dashboard) { {'pe_ver' => test_pe_ver} }

          it 'includes the dashboard and installs pe' do

            expect(subject).to receive(:is_pre_aio_version?).and_return(test_is_pre_aio_version)
            expect(subject).to receive(:use_meep?).with(master['pe_ver'] || options['pe_ver']).and_return(test_use_meep)

            # TODO: is allow acceptable here? expect caused error with '3 times'
            allow(subject).to receive(:master).and_return(master)

            expect(subject).to receive(:compile_masters).and_return(compile_masters)
            expect(subject).to receive(:dashboard).and_return(dashboard)

            # TODO: handle custom answers?

            # TODO: handle pe_version master / options?

            # TODO: version_is_less??
            expect(subject).to receive(:version_is_less).with(test_pe_ver, test_boundary_version).and_return(test_version_is_less)

            expect(subject).to receive(:install_lei).once
            subject.perf_install_pe

          end

        end

      end

    end

    context 'when pe is a pre-aio version' do

      test_is_pre_aio_version = true

      it 'installs pe without including the dashboard' do

        expect(subject).to receive(:is_pre_aio_version?).and_return(test_is_pre_aio_version)
        expect(subject).to receive(:install_lei)
        subject.perf_install_pe

      end


    end

  end

  describe '#has_cent7_repo?' do

    let(:test_beaker_log) { Class.new }

    context 'when the package is not available' do

      test_package = 'testing'
      test_version = '1.2.3'

      it 'returns false' do
        stub_const('Beaker::Log', test_beaker_log)
        expect(test_beaker_log).to receive(:notify).with(a_string_starting_with("Skipping #{test_package} version #{test_version}"))
        expect(subject.has_cent7_repo?(test_package, test_version)).to eq(false)
      end
    end

    context 'when the package is available but the version is not' do

      test_package = 'bolt'
      test_version = '0.0.0'

      it 'returns false' do
        stub_const('Beaker::Log', test_beaker_log)
        expect(test_beaker_log).to receive(:notify).with(a_string_starting_with("Skipping #{test_package} version #{test_version}"))
        expect(subject.has_cent7_repo?(test_package, test_version)).to eq(false)
      end

    end

    context 'when the package / version is available' do

      test_package = 'bolt'
      test_version = '0.2'

      it 'returns true' do
        stub_const('Beaker::Log', test_beaker_log)
        expect(test_beaker_log).to receive(:notify).with(a_string_starting_with("Found Cent7 repo for #{test_package} version #{test_version}"))
        expect(subject.has_cent7_repo?(test_package, test_version)).to eq(true)
      end
    end

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

      it 'sets the tmp_module_dir' do
        pending('.install_deps')

        subject.install_deps
      end

      it 'installs the jq package' do
        pending('.install_deps')

        subject.install_deps
      end

  end


  context '.setup_gatling_proxy' do

  end


end

