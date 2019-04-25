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
  let!(:hosts) {[Beaker::Host.create('master', {'platform' => Beaker::Platform.new('centos-6.5-x86_64'), 'role' => 'master'}, {:logger => @logger})]}
  let(:test_beaker_log) { Class.new }
  let(:test_net_http) { Class.new }
  let(:test_http_response) { Class.new }

  context '.set_etc_hosts' do
    let!(:master) {[]}

    it 'it sets the puppet ip in /etc/hosts' do

      # TODO: test loadbalancer.ip and master.ip

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
      expect(subject.hosts[0]).to receive(:install_package).with("https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.5.noarch.rpm", '', nil, :acceptable_exit_codes => [0,1])
      expect(subject).to receive(:on).with(hosts, 'setenforce 0 || true').once
      expect(subject).to receive(:on).with(hosts, "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux").once
      expect(subject).to receive(:on).with(hosts, 'yum install -y nc || true').once
      subject.install_epel_packages
    end

    it 'executes the el6 platform only command' do
      hosts[0]['platform'] = Beaker::Platform.new('el-6-x86_64')
      allow(subject).to receive(:hosts).and_return(hosts)
      allow(subject).to receive(:agents).and_return(hosts)
      expect(subject.hosts[0]).to receive(:install_package).with("https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm", '', nil, :acceptable_exit_codes => [0,1])
      allow(subject).to receive(:on)
      expect(subject).to receive(:on).with(hosts[0], 'chkconfig iptables off').once
      subject.install_epel_packages
    end

  end

  context '.setup_r10k' do

    let!(:masters) {[{'platform' => Beaker::Platform.new('centos-6.5-x86_64')}]}

    it 'installs git on each master' do

      allow(subject).to receive(:masters).and_return(masters)
      expect(subject).to receive(:select_hosts).with({:roles => ['master', 'compile_master']}).and_return(masters)

      expect(subject).to receive(:install_package).with(masters[0], 'git')
      subject.setup_r10k

    end

  end

  describe '#download_file' do
    url = 'http://test.com/file'
    destination = '/tmp/file'

    context 'when the specified URL exists' do
      let(:test_download) { Class.new }

      context 'when the download is successful' do
        it 'reports the download and raises no errors' do
          expect(subject).to receive(:link_exists?).with(url).and_return(true)
          expect(subject).to receive(:puts).with("Downloading #{url} to #{destination}")
          expect(subject).to receive(:open).with(url).and_return(test_download)
          expect(IO).to receive(:copy_stream).with(test_download, destination)
          expect(File).to receive(:exists?).with(destination).and_return(true)

          subject.download_file(url, destination)
        end
      end

      context 'when the download is not successful' do
        it 'reports the download and raises an error' do
          expect(subject).to receive(:link_exists?).with(url).and_return(true)
          expect(subject).to receive(:puts).with("Downloading #{url} to #{destination}")
          expect(subject).to receive(:open).with(url).and_return(test_download)
          expect(IO).to receive(:copy_stream).with(test_download, destination)
          expect(File).to receive(:exists?).with(destination).and_return(false)

          expect{ subject.download_file(url, destination) }
              .to raise_error(RuntimeError, 'Download was not successful')
        end
      end

    end

    context 'when the specified URL does not exist' do
      context 'when the download is successful' do
        it 'raises an errors' do
          expect(subject).to receive(:link_exists?).with(url).and_return(false)
          expect(subject).not_to receive(:puts).with("Downloading #{url} to #{destination}")
          expect(subject).not_to receive(:open).with(url)
          expect(IO).not_to receive(:copy_stream)
          expect(File).not_to receive(:exists?).with(destination)

          expect{ subject.download_file(url, destination) }
              .to raise_error(RuntimeError, "Specified URL does not exist: #{url}")
        end
      end

    end

  end

  context 'puppet_module_dependencies' do
    let!(:masters) {hosts}
    let!(:master) {hosts[0]}

    it 'supports older puppet version dependencies' do
      allow(subject).to receive(:master).and_return(master)

      result = Beaker::Result.new(master, 'puppet --version')
      result.stdout = '5.9.0'
      expect(subject).to receive(:on).with(master, 'puppet --version').and_return(result)
      expect(subject).to receive(:on).with(master, "sed -i '/puppetlabs\\/.*_core/d' /etc/puppetlabs/code-staging/environments/production/Puppetfile")
      expect(subject).to receive(:on).with(master, "rm -rf /etc/puppetlabs/code-staging/environments/production/modules/*_core")

      subject.puppet_module_dependencies
    end

    it 'supports older puppet version dependencies' do
      allow(subject).to receive(:master).and_return(master)

      result = Beaker::Result.new(master, 'puppet --version')
      result.stdout = '6.1.0'
      expect(subject).to receive(:on).with(master, 'puppet --version').and_return(result)

      subject.puppet_module_dependencies
    end

  end

  # TODO: refactor to remove duplication
  describe '#perf_install_pe' do
    context 'when pe is not a pre-aio version' do
      test_is_pre_aio_version = false

      before do
        test_options = { answers: {} }
        subject.instance_variable_set(:@options, test_options)
      end

      test_pe_ver = '2017.3'
      let!(:master) { { 'pe_ver' => test_pe_ver } }

      it 'includes the dashboard and installs pe' do
        expect(subject).to \
          receive(:is_pre_aio_version?).and_return(test_is_pre_aio_version)

        expect(subject).to receive(:install_lei).once
        subject.perf_install_pe

        options = subject.instance_variable_get(:@options)
        expect(options.keys). to include :answers
        expect(options[:answers]). to include \
          'puppet_enterprise::profile::master::r10k_remote' =>
            '/opt/puppetlabs/server/data/puppetserver/r10k/control-repo'
        expect(options[:answers]). to include \
          'puppet_enterprise::profile::puppetdb::node_ttl' => '0s'
      end
    end

    context 'when pe is a pre-aio version' do
      test_is_pre_aio_version = true

      it 'installs pe without including the dashboard' do
        expect(subject).to \
          receive(:is_pre_aio_version?).and_return(test_is_pre_aio_version)
        expect(subject).to receive(:install_lei)
        subject.perf_install_pe
      end
    end
  end

  describe '#has_cent7_repo?' do

    context 'when the package / version is available' do

      test_response_code = '200'
      test_package = 'bolt'
      test_version = '0.2'

      it 'returns true' do
        stub_const('Beaker::Log', test_beaker_log)

        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:start).and_return(test_response_code)

        expect(test_beaker_log).to receive(:notify).with(a_string_starting_with("Found Cent7 repo for #{test_package} version #{test_version}"))
        expect(subject.has_cent7_repo?(test_package, test_version)).to eq(true)
      end

    end

    context 'when the package is not available' do

      test_response_code = '404'
      test_package = 'testing'
      test_version = '1.2.3'

      it 'returns false' do
        stub_const('Beaker::Log', test_beaker_log)

        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:start).and_return(test_response_code)

        expect(test_beaker_log).to receive(:notify).with(a_string_starting_with("Skipping #{test_package} version #{test_version}"))
        expect(subject.has_cent7_repo?(test_package, test_version)).to eq(false)
      end

    end

    context 'when the package is available but the version is not' do

      test_response_code = '404'
      test_package = 'bolt'
      test_version = '0.0.0'

      it 'returns false' do
        stub_const('Beaker::Log', test_beaker_log)

        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:start).and_return(test_response_code)

        expect(test_beaker_log).to receive(:notify).with(a_string_starting_with("Skipping #{test_package} version #{test_version}"))
        expect(subject.has_cent7_repo?(test_package, test_version)).to eq(false)
      end

    end

  end

  describe '#get_cent7_repo' do

    context 'when response_lines contains the package' do

      test_response_lines = ['<tr><td><a href="5.2.1.master.SNAPSHOT.2018.03.15T0954/?C=M&amp;O=D">5.2.1.master.SNAPSHOT.2018.03.15T0954/</a></td><td>-</td><td>15-Mar-2018 09:57</td></tr>']
      test_package = 'puppetserver'
      test_expected_result = '5.2.1.master.SNAPSHOT.2018.03.15T0954'

      it 'returns the package' do
        stub_const('Beaker::Log', test_beaker_log)
        allow(test_beaker_log).to receive(:notify)
        allow(subject).to receive(:has_cent7_repo?).and_return(true)
        expect(subject.get_cent7_repo(test_response_lines, test_package)).to eq(test_expected_result)
      end

    end

    context 'when response_lines does not contain the package' do

      test_response_lines = ['<tr><td><a href="xyz/?C=M&amp;O=D">xyz/</a></td><td>-</td><td>15-Mar-2018 09:57</td></tr>']
      test_package = 'puppetserver'
      test_expected_result = nil

      it 'returns nil' do
        stub_const('Beaker::Log', test_beaker_log)
        allow(test_beaker_log).to receive(:notify)
        allow(subject).to receive(:has_cent7_repo?).and_return(false)
        expect(subject.get_cent7_repo(test_response_lines, test_package)).to eq(test_expected_result)
      end

    end

  end

  describe '#get_latest_server_version' do

    test_response_lines = [
        '<tr><td><a href="5.3.1.SNAPSHOT.2018.03.26T1400/?C=M&amp;O=D">5.3.1.SNAPSHOT.2018.03.26T1400/</a></td><td>-</td><td>26-Mar-2018 14:03</td></tr>',
        '<tr><td><a href="5.3.1.SNAPSHOT.2018.03.26T0851/?C=M&amp;O=D">5.3.1.SNAPSHOT.2018.03.26T0851/</a></td><td>-</td><td>26-Mar-2018 10:24</td></tr>',
        '<tr><td><a href="6.0.0.master.SNAPSHOT.2018.03.26T1014/?C=M&amp;O=D">6.0.0.master.SNAPSHOT.2018.03.26T1014/</a></td><td>-</td><td>26-Mar-2018 10:17</td></tr>'
    ]

    context 'when version is included in test_response_lines' do

      test_version = '5.3.1.SNAPSHOT.2018.03.26T0851'
      test_response_code = '200'
      test_expected_result = test_version

      it 'returns the expected server version' do
        stub_const('Beaker::Log', test_beaker_log)
        allow(test_beaker_log).to receive(:notify)

        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:get).and_return(test_http_response)
        allow(test_net_http).to receive(:start).and_return(test_response_code)
        allow(test_http_response).to receive(:lines).and_return(test_response_lines)

        expect(subject.get_latest_server_version(test_version)).to eq(test_expected_result)

      end

    end

    context 'when version is not included in test_response_lines' do

      test_version = '0.0.0.SNAPSHOT.2018.03.26T0851'
      test_response_code = '200'
      test_expected_result = nil

      it 'returns nil' do
        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:get).and_return(test_http_response)
        allow(test_net_http).to receive(:start).and_return(test_response_code)
        allow(test_http_response).to receive(:lines).and_return(test_response_lines)

        expect(subject.get_latest_server_version(test_version)).to eq(test_expected_result)

      end

    end

  end

  describe '#get_latest_agent_version' do

    context 'when the URL response code is 200' do

      test_response_code = '200'
      test_response_body = '{"build-date":"1521577908","suite-version":"5.4.0.580.g88a47a8","suite-commit":"88a47a8e2fbcd6009d6fdaf9f388dcd441ce4850","puppet":"bf26912312ff3481527452782a684c639e9b466e","facter":"00da6691664829baac33c9a9a07c522cd4d57649","hiera":"5150beae7aab405c21c2072a9c79f57cbfda104a","pxp-agent":"c648a3a12a5cf7adbe56e45d56216c6a7966bd8d"}'
      test_response_message = 'success message'
      test_expected_result = '88a47a8e2fbcd6009d6fdaf9f388dcd441ce4850'

      it 'returns the agent version' do

        stub_const('Beaker::Log', test_beaker_log)
        allow(test_beaker_log).to receive(:notify)

        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:get_response).and_return(test_http_response)
        allow(test_http_response).to receive(:code).and_return(test_response_code)
        allow(test_http_response).to receive(:body).and_return(test_response_body)
        allow(test_http_response).to receive(:message).and_return(test_response_message)

        expect(subject.get_latest_agent_version).to eq(test_expected_result)

      end

    end

    context 'when the URL response code is not 200' do

      test_response_code = '404'
      test_response_message = 'error message'
      test_expected_log_output = /.*http.*, error: #{test_response_code}, #{test_response_message}/
      test_expected_result = nil

      it 'logs the error' do

        stub_const('Beaker::Log', test_beaker_log)
        allow(test_beaker_log).to receive(:notify)

        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:get_response).and_return(test_http_response)
        allow(test_http_response).to receive(:code).and_return(test_response_code)
        allow(test_http_response).to receive(:message).and_return(test_response_message)

        expect(test_beaker_log).to receive(:notify).with(match(test_expected_log_output))
        expect(subject.get_latest_agent_version).to eq(test_expected_result)

      end

    end

  end

  describe '#get_latest_release_agent_version' do

    context 'when the response contains the agent version' do

      test_response_lines = [
          '<tr><td><a href="xyz/?C=M&amp;O=D"> xyz/</a></td><td>-</td><td>20-Mar-2018 20:38</td></tr>',
          '<tr><td><a href="5.5.0/?C=M&amp;O=D">5.5.0/</a></td><td>-</td><td>20-Mar-2018 19:37</td></tr>',
          '<tr><td><a href="abc/?C=M&amp;O=D"> abc/</a></td><td>-</td><td>20-Mar-2018 17:58</td></tr>',
          '<tr><td><a href="123/?C=M&amp;O=D"> 123/</a></td><td>-</td><td>12-Mar-2018 17:54</td></tr>',
          '<tr><td><a href="5.4.0/?C=M&amp;O=D">5.4.0/</a></td><td>-</td><td>16-Feb-2018 17:18</td></tr>',
          '<tr><td><a href="5.3.5/?C=M&amp;O=D">5.3.5/</a></td><td>-</td><td>13-Feb-2018 21:25</td></tr>'
      ]

      test_response_code = '200'
      test_expected_result = '5.5.0'

      it 'returns the agent version' do

        stub_const('Beaker::Log', test_beaker_log)
        allow(test_beaker_log).to receive(:notify)

        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:get).and_return(test_http_response)
        allow(test_net_http).to receive(:start).and_return(test_response_code)
        allow(test_http_response).to receive(:lines).and_return(test_response_lines)

        expect(subject.get_latest_release_agent_version).to eq(test_expected_result)
      end

    end

    context 'when the response does not contain the agent version' do

      test_response_lines = ['<tr><td><a href="xyz/?C=M&amp;O=D">xyz/</a></td><td>-</td><td>13-Feb-2018 21:25</td></tr>']
      test_response_code = '200'
      test_expected_result = nil

      it 'returns nil' do

        stub_const('Beaker::Log', test_beaker_log)
        allow(test_beaker_log).to receive(:notify)

        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:get).and_return(test_http_response)
        allow(test_net_http).to receive(:start).and_return(test_response_code)
        allow(test_http_response).to receive(:lines).and_return(test_response_lines)

        expect(subject.get_latest_release_agent_version).to eq(test_expected_result)

      end

    end

    context 'when the response code is not 200' do

      test_response_lines = ['<tr><td><a href="5.3.5/?C=M&amp;O=D">5.3.5/</a></td><td>-</td><td>13-Feb-2018 21:25</td></tr>']
      test_response_code = '404'
      test_expected_result = nil

      it 'returns nil' do

        stub_const('Beaker::Log', test_beaker_log)
        allow(test_beaker_log).to receive(:notify)

        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:get).and_return(test_http_response)
        allow(test_net_http).to receive(:start).and_return(test_response_code)
        allow(test_http_response).to receive(:lines).and_return(test_response_lines)

        expect(subject.get_latest_release_agent_version).to eq(test_expected_result)

      end

    end

  end

end

