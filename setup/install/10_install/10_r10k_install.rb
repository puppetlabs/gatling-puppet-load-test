require 'classification_helper'

# how many forge module role classes should we build?
def number_of_roles
  num_roles = (options[:scale] && options[:scale][:module_roles]).to_i
  num_roles = 100 if num_roles < 1
  num_roles
end

test_name 'prepare r10k or code_manager on master(s)' do
  cache_path = '/opt/puppetlabs/server/data/puppetserver/r10k/'

  if(options[:forge_host])
    #Use the alternative forge for this test
    hosts.each do |host|
      stub_forge_on(host)
    end
  end

  pe_version = (options[:pe_ver] || master['pe_ver'])
  # If this is PE 2015.3+ then we have code_manager and are just manipulating
  # the control-repo on the MoM prior to code_manager deploy. On PE 2015.2 or
  # < we are using r10k directly to coordinate code on all masters.
  masters = version_is_less(pe_version, '2015.3') ?
    select_hosts({:roles => ['master', 'compile_master']}) :
    [master]

  step 'install / configure r10k gem if PE 3.8' do
    # If we are installing PE 3.8 to test an upgrade, we need to manually install and configure the r10k gem
    if version_is_less(pe_version, '2015.2')
      on masters, "#{master['privatebindir']}/gem install r10k"
      environment_path = master.puppet['environmentpath']
      r10k_config = <<YAML
:cachedir: /var/cache/r10k
:sources:
  :puppet:
    remote: #{cache_path}/control-repo
    basedir: #{environment_path}
:purgedirs:
  - #{environment_path}
YAML
      on masters, 'mkdir -p /etc/puppetlabs/r10k'
      create_remote_file(masters, '/etc/puppetlabs/r10k/r10k.yaml', r10k_config)
    end
  end

  step 'install bundler gem used by control forge module scripts' do
    masters.each do |node|
      # Starting with 2016.2.x (MEEP), pe-bundler is now installed all the time,
      # regardless of if the user is installing higgs. There currently exists
      # a conflict between pe-bundler and bundler, which errors out trying to install bundler
      # if pe-bundler is installed.
      if !node.check_for_package('pe-bundler')
        on(node, "#{node['privatebindir']}/gem install bundler --no-ri --no-rdoc")
      end
    end
  end

  step 'clone control repo locally' do
    r10k_remote = options[:r10k_remote] || \
      'git@github.com:puppetlabs/puppet-scale-control.git'

    masters.each do |node|
      on node, "mkdir -p #{cache_path} && \
        cd #{cache_path} && \
        rm -rf control-repo && \
        git clone #{r10k_remote} control-repo && \
        cd control-repo && git checkout production"
    end
  end

  step "generate role classes which wrap forge module profile classes" do
    masters.each do |node|

      # ec2 vm's don't have GCC installed to build native gems, which is currently required for json
      install_package(node, 'gcc')

      # Do a bundle install in the production environment path.
      on node, "cd #{cache_path}/control-repo && \
        #{node['privatebindir']}/bundle install --path vendor"

      # Clean up any existing role classes. It is possible (if multiple setup runs
      # occur on this system) that these are already being locally tracked via
      # git, in which case let's `git rm -r` them, otherwise, just clean up the
      # files if they are present.
      on node, "(cd #{cache_path}/control-repo && \
        git rm -r site/role/manifests/node) || \
        rm -rf #{cache_path}/control-repo/site/role/manifests/node"

      # By default, generate 100 role classes (which should be sufficient up to
      # ~100,000 agent nodes, based on statistics gathered from runs of
      # `#node_role_distribution`).  Allow for overriding via the config file.
      on node, "cd #{cache_path}/control-repo && \
        #{node['privatebindir']}/bundle exec #{node['privatebindir']}/ruby script/generate_node_roles.rb #{number_of_roles}"
    end
  end

  step "update r10k repository" do
    masters.each do |node|
      # enable git config user.{email,name} for committing to the r10k repo
      override_git_user_and_email(node, "#{cache_path}/control-repo", 'Beaker Test User', 'no-reply@puppet.com')

      # Commit role class changes to git, so r10k won't wipe them out on later
      # runs. Here we check out a working copy of the `production` environment
      # to be able to commit (otherwise we are in a "detached HEAD" situation).
      # It is possible that a check out already exists, so fail gracefully and
      # just switch to the `production` branch if it is available.
      on node, "cd #{cache_path}/control-repo && \
        git checkout production && \
        git add site/role/manifests/node && \
        git commit -m 'updating role manifests'"
    end
  end

  step "create additional environments" do
    envs           = (options[:scale] && options[:scale][:environments]) || 5
    head_refs_path = "#{cache_path}/control-repo/.git/refs/heads"

    masters.each do |node|
      # first, actually remove all non-production environment branches
      on node, "cd #{head_refs_path} && \
        (ls | grep -v '^production$' | xargs --no-run-if-empty rm)"

      # copy the production environment ref the specified number of times
      on node, "cd #{head_refs_path} && \
        (for i in `seq 1 #{envs}`; do cp production environment_${i}; done)"
    end
  end

  if hieradata_dir = master['hieradata_dir_used_in_install']
    step "pull in hieradata used during installation into the MoM's repo so that it continues to be enforced" do
      on master, "cp -r #{hieradata_dir} #{cache_path}/control-repo && \
         cd #{cache_path}/control-repo && \
         git add hieradata && \
         git commit -m 'including hieradata from install'"
    end
  end

  step "deploy production environment" do
    deploy_environment('production', masters)
  end
end
