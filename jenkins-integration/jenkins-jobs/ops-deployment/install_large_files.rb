test_name 'Prepare OPS master for Gatling testing'

step 'Clone test-catalogs-large-files repo onto master' do
  create_remote_file(master, '/root/.ssh/known_hosts', <<-EOF)
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOF

  if !check_for_package(master, 'git')
    install_package(master, 'git')
  end

  on(master, 'git clone git@github.com:puppetlabs/test-catalogs-large-files.git --depth 1')
end

step 'Unzip OPS tarball into code-staging' do
  on(master, <<-EOF)
cd /root/test-catalogs-large-files/ops-environment-2015.12.07 &&
cat ops_environments.tar.gz.* > ops_environment.tar.gz &&
tar xvzf ops_environment.tar.gz &&
rm -rf /etc/puppetlabs/code-staging/environments &&
mv environments /etc/puppetlabs/code-staging
EOF

  # Set owner to prevent permissions errors during file sync
  on(master, 'chown -R pe-puppet:pe-puppet /etc/puppetlabs/code-staging/environments')
end
