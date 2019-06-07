# frozen_string_literal: true

test_name "Install Catalog Zero modules"

step "Clone test-catalogs repo onto master" do
  create_remote_file(master, "/root/.ssh/known_hosts", <<~KNOWN_HOSTS)
    github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
  KNOWN_HOSTS

  install_package(master, "git") unless check_for_package(master, "git")

  on(master, '[ -d "test-catalogs" ] || git clone git@github.com:puppetlabs/test-catalogs.git --depth 1')
end

step "Unzip OPS tarball into code-staging" do
  on(master, <<~CP_CMD)
    cd /root/test-catalogs/catalog_zero/modules &&
    cp -r * /etc/puppetlabs/code-staging/environments/production/modules
  CP_CMD

  # Set owner to prevent permissions errors during file sync
  on(master, "chown -R pe-puppet:pe-puppet /etc/puppetlabs/code-staging/environments")
end
