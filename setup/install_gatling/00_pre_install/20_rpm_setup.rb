test_name 'Setup and configure machines for metrics gathering' do
  skip_test "No need to add epel if we are not collecting metrics" unless any_hosts_as?(:metric)
  confine :to, :platform => ['el-6-x86_64', 'el-7-x86_64']


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

  step 'install atop, lsof for metrics gathering' do
    on hosts, 'yum install -y atop || true'
    on hosts, 'yum install -y lsof || true'
  end

  step 'enable atop service' do
    on hosts, 'chkconfig atop on'
    on hosts, 'service atop start'
  end

  step 'ensure iptables chkconfig is disabled on el6' do
    if :platform == 'el-6-x86_64'
      on hosts, 'chkconfig iptables off'
    end
  end
end
