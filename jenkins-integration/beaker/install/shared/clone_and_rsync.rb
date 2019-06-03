# frozen_string_literal: true

def clone_puppet_repo(repo)
  on(master, "git clone #{repo}")
end

def checkout_puppet_ref(ref)
  on(master, "pushd puppet; git checkout #{ref}; popd")
end

def rsync_puppet
  on(master, "rsync -avg ~/puppet/lib/* /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/")
end

step "ensure git and rsync are installed" do
  install_package(master, "git") unless check_for_package(master, "git")

  install_package(master, "rsync") unless check_for_package(master, "rsync")
end

step "Cleanup the directory first"
on(master, "rm -rf puppet")

step "Cloning desired puppet repo '#{ENV['PUPPET_REMOTE']}'"
# Add github known_hosts entry otherwise host verification will fail
on(master, "ssh-keyscan -H github.com >> ~/.ssh/known_hosts")
clone_puppet_repo(ENV["PUPPET_REMOTE"])

step "Checking out desired ref '#{ENV['PUPPET_REF']} from puppet repo"
checkout_puppet_ref(ENV["PUPPET_REF"])

step "Rsyncing puppet into place on top of the packaged version"
rsync_puppet
