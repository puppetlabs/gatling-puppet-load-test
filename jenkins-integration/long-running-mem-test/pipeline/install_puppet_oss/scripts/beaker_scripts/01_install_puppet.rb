test_name "Install Puppet FOSS"

step "== Install Puppet FOSS"
platform = "el-6"
arch = "x86_64"

puppet_version = "3.7.4"
puppetserver_version = "1.0.0"

repo_d_dir = "/etc/yum.repos.d/"
puppet_repo_url = "http://builds.puppetlabs.lan/puppet/#{puppet_version}/repo_configs/rpm/pl-puppet-#{puppet_version}-#{platform}-#{arch}.repo"
puppetserver_repo_url = "http://builds.puppetlabs.lan/puppetserver/#{puppetserver_version}/repo_configs/rpm/pl-puppetserver-#{puppetserver_version}-#{platform}-#{arch}.repo"

hosts.each do |host|
  step "Add puppet repo to yum"
  on host, "wget #{puppet_repo_url} -P #{repo_d_dir}"

  step "Add puppetserver repo to yum"
  on host, "wget #{puppetserver_repo_url} -P #{repo_d_dir}"

  step "Install puppet package"
  install_package host, "puppet"

  step "Install puppetserver package"
  install_package host, "puppetserver"

  step "Start puppetserver"
  on host, "service puppetserver start"
end
