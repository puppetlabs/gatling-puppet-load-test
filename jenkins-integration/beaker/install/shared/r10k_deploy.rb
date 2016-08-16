require 'puppet/gatling/config'

test_name "Deploy r10k control repository"

R10K_DIR = '/opt/puppetlabs/scratch/perf_testing/r10k'
R10K_CONFIG_PATH = "#{R10K_DIR}/r10k.yaml"

## TODO This probably needs more work to finish hooking up everything that
##      comes in the control repository, like a hiera.yaml config file.
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

  r10k_config_contents = <<EOS
:cachedir: '#{cachedir}'

:sources:
  :perf-test:
    remote: '#{r10k_config[:control_repo]}'
    basedir: '#{r10k_config[:basedir]}'
EOS

  create_remote_file(host, R10K_CONFIG_PATH, r10k_config_contents)
end

def run_r10k_deploy(host, bin, environments, exec_options)
  r10k = "#{bin}/r10k"
  results = {}
  environments.each do |env|
    result = on(host, "#{r10k} deploy environment #{env} -p -v debug -c #{R10K_CONFIG_PATH}",
                exec_options)
    results[env] = result.exit_code
  end
  results
end


########################

bin = ENV['PUPPET_BIN_DIR']
r10k_version = ENV['PUPPET_R10K_VERSION']

step "Install git" do
  on(master, puppet_resource("package git ensure=installed"))
end

step "Set up SSH key for github access" do
  if !master.file_exist?("/root/.ssh/id_rsa")
    result = curl_on master, "-o /root/.ssh/id_rsa 'http://int-resources.ops.puppetlabs.net/QE%20Shared%20Resources/travis_keys/id_rsa'"
    assert_equal 0, result.exit_code

    on(master, "chmod 600 /root/.ssh/id_rsa")

    result = curl_on master, "-o /root/.ssh/id_rsa.pub 'http://int-resources.ops.puppetlabs.net/QE%20Shared%20Resources/travis_keys/id_rsa.pub'"
    assert_equal 0, result.exit_code
  end
end

step "add github to known hosts" do
  # Create known_hosts file with GitHub host key to prevent
  # "Host key verification failed" errors during clones
  create_remote_file(master, "/root/.ssh/known_hosts", <<-EOS)
  github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
  EOS
end

step "install and configure r10k" do
  r10k_config = get_r10k_config_from_env()
  if r10k_config
    install_r10k(master, bin, r10k_version)
    create_r10k_config(master, r10k_config)

    # This is straight up horrific.  Sorry.
    # Old versions of r10k can do fun things like throw NPEs and return a non-zero
    # exit code even when they've actually successfully deployed.  If you then
    # simply re-run the same r10k command afterward, it'll get a zero exit code.
    # So, we will do an initial deploy and then if we got any non-zero exit codes,
    # we'll try those environments one more time.  Sorry.
    results = run_r10k_deploy(master, bin, r10k_config[:environments],
                              {:acceptable_exit_codes => [0, 1]})
    failed_envs = results.select { |env,exit_code| exit_code == 1 }.keys
    if failed_envs.size > 0
      Beaker::Log.warn("R10K deploy failed on environments: #{failed_envs}; trying one more time.")
      run_r10k_deploy(master, bin, failed_envs, {})
    end
  else
    raise "No R10K config found in environment!"
  end
end
