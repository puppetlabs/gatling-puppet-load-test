test_name 'Setup and configure machines for metrics gathering' do
  skip_test "No need setup docker if we are not collecting metrics" unless any_hosts_as?(:metric)
  confine :to, :platform => ['el-6-x86_64', 'el-7-x86_64']
  install_docker
  on(metric,"systemctl start docker")
  on(metric,"docker pull pcr-internal.puppet.net/pe-and-platform/gplt")

end
