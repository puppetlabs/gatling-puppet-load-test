# NOTE:
#   This copies your personal ~/.ssh/id_rsa and ~/.ssh/id_rsa-acceptance keys
#   onto the jenkins-gatling machine.
#
#   It is expected that appropriate keys will be used "in production"
#   (i.e. keys with these names will be available in the expected locations).
#   For development though we can just use the ones you have on your machine.

test_name 'Configure SSH for cloning and host communication'

# Often times you'll want to SSH in to the jenkins machine and run commands
# manually, which will be done as the root user. Copy your keys for convenience.
# scp_to(jenkins, "#{ENV['HOME']}/.ssh/id_rsa", "/root/.ssh/id_rsa")
# on(jenkins, "eval $(ssh-agent -t 24h -s) && ssh-add /root/.ssh/id_rsa")

# When our jobs run in Jenkins they will need to start an ssh-agent
# and add these keys, which can be referenced within the job by
# ${HOME}/.ssh/id_rsa*
# The id_rsa key is used for cloning private repos from GitHub, and the
# id_rsa-acceptance key is used for remote access between the host machines.
jenkins_sshdir = '/var/lib/jenkins/.ssh'
on(jenkins, "mkdir -p #{jenkins_sshdir}")
# scp_to(jenkins, "#{ENV['HOME']}/.ssh/id_rsa", "#{jenkins_sshdir}/id_rsa")
scp_to(jenkins, "#{ENV['HOME']}/.ssh/id_rsa-acceptance", "#{jenkins_sshdir}/id_rsa-acceptance")

# Create known_hosts file with GitHub host key to prevent
# "Host key verification failed" errors during clones
create_remote_file(jenkins, "#{jenkins_sshdir}/known_hosts", <<-EOF)
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOF

# Everything used during the jenkins job run must be owned by jenkins:jenkins
on(jenkins, "chown -R jenkins:jenkins #{jenkins_sshdir}")
