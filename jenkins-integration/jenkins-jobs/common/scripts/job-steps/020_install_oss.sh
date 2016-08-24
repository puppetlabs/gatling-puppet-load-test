#!/bin/bash

pushd jenkins-integration
source jenkins-jobs/common/scripts/job-steps/initialize_ruby_env.sh

# This job sets up the following:
# - Specified OSS Puppet Server / puppet-agent versions installed on provided master

set -x
set -e

# Setup SSH agent for SSH access to the SUT
eval $(ssh-agent -t 24h -s)
ssh-add ${HOME}/.ssh/id_rsa

# TODO: get rid of references to ops-deployment

bundle exec beaker \
        --config hosts.yaml \
        --type aio \
        --load-path lib \
        --log-level debug \
        --no-color \
        --tests \
beaker/install/shared/hack_hostname_into_etc_hosts.rb,\
beaker/install/shared/disable_firewall.rb,\
beaker/install/foss/30_install_dev_repos.rb,\
beaker/install/foss/70_install_puppet.rb,\
beaker/install/shared/configure_permissive_server_auth.rb,\
beaker/install/shared/99_restart_server.rb

echo "Finished installing OSS Puppet Server!"

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd


