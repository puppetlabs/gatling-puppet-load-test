test_name "Install r10k"

def install_r10k(host)
  gem = '/opt/puppetlabs/puppet/bin/gem'
  on(host, "#{gem} install r10k --no-document")
end

# NOTE: this section initializes the r10k configuration on the SUT
#  machine.  For development purposes you might want to set the
#  `remote` (control repo) to point at your fork or even a local
#  git daemon, but for the most part it should stay pinned to
#  the PL control repo for production use.

def create_r10k_config(host)
  configdir = '/etc/puppetlabs/r10k'
  on(host, "mkdir -p #{configdir}")
  r10k_config = <<EOS
# The location to use for storing cached Git repos
:cachedir: '/opt/puppetlabs/r10k/cache'

# A list of git repositories to create
:sources:
  # This will clone the git repository and instantiate an environment per
  # branch in /etc/puppetlabs/code/environments
  :puppetserver-perf-driver:
    remote: 'git@github.com:puppetlabs/puppetlabs-puppetserver_perf_driver_dev_control'
    basedir: '/etc/puppetlabs/code/environments'
EOS
  create_remote_file(host, "#{configdir}/r10k.yaml", r10k_config)
end


step "Install git" do
  on(jenkins, puppet_resource("package git ensure=installed"))
end

step "Set up SSH key for github access" do
  if !jenkins.file_exist?("/root/.ssh/id_rsa")
    result = curl_on jenkins, "-o /root/.ssh/id_rsa 'http://int-resources.ops.puppetlabs.net/QE%20Shared%20Resources/gatling_test_keys/id_rsa'"
    assert_equal 0, result.exit_code

    on(jenkins, "chmod 600 /root/.ssh/id_rsa")
  end
  if !jenkins.file_exist?("/root/.ssh/id_rsa.pub")
    result = curl_on jenkins, "-o /root/.ssh/id_rsa.pub 'http://int-resources.ops.puppetlabs.net/QE%20Shared%20Resources/gatling_test_keys/id_rsa.pub'"
    assert_equal 0, result.exit_code
  end
end

step "add github to known hosts" do
  # Create known_hosts file with GitHub host key to prevent
  # "Host key verification failed" errors during clones
  create_remote_file(jenkins, "/root/.ssh/known_hosts", <<-EOS)
  github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
  EOS
end

step "Install r10k" do
  install_r10k(jenkins)
end

step "Set up r10k config" do
  create_r10k_config(jenkins)
end
