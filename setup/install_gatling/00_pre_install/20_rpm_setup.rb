# frozen_string_literal: true

test_name "Setup and configure machines for metrics gathering" do
  skip_test "No need to add epel if we are not collecting metrics" unless any_hosts_as?(:metric)
  confine :to, platform: ["el-6-x86_64", "el-7-x86_64"]
  install_epel_packages
end
