# TODO: clean up.  this code is copied into jenkins-jobs/ops-deployment/install_catalog_zero.rb

# test_name 'Clone test-catalogs repo onto master'
#
# create_remote_file(master, '/root/.ssh/known_hosts', <<-EOF)
# github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
# EOF
#
# if !check_for_package(master, 'git')
#   install_package(master, 'git')
# end
#
# on(master, 'git clone git@github.com:puppetlabs/test-catalogs.git /root/test-catalogs --depth 1')
