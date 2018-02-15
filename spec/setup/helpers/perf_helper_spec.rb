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

  context '.install_epel_packages' do

    it 'executes all commands to set up epel and packages' do
      allow(subject).to receive(:hosts).and_return(hosts)
      allow(subject).to receive(:agents).and_return(hosts)
      expect(subject.hosts[0]).to receive(:install_package).with("https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.5.noarch.rpm", '', nil, :acceptable_exit_codes => [0,1])
      expect(subject).to receive(:on).with(hosts, 'setenforce 0 || true').once
      expect(subject).to receive(:on).with(hosts, "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux").once
      expect(subject).to receive(:on).with(hosts, 'yum install -y nc || true').once
      expect(subject).to receive(:on).with(hosts, 'yum install -y atop || true').once
      expect(subject).to receive(:on).with(hosts, 'yum install -y lsof || true').once
      expect(subject).to receive(:on).with(hosts, 'chkconfig atop on').once
      expect(subject).to receive(:on).with(hosts, 'service atop start').once
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

end

