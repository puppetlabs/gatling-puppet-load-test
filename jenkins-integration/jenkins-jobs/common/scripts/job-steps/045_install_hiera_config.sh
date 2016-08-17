#!/bin/bash

pushd jenkins-integration
source jenkins-jobs/common/scripts/job-steps/initialize_ruby_env.sh

# This file copies a hiera configuration file from a custom location to the
# spot where Puppet expects to find it.

set -x
set -e

# Setup SSH agent for SSH access to SUT
eval $(ssh-agent -t 24h -s)
ssh-add ${HOME}/.ssh/id_rsa

bundle exec beaker \
        --config hosts.yaml \
        --load-path lib \
        --log-level debug \
        --no-color \
        --tests \
beaker/install/shared/45_install_hiera_config.rb,\
beaker/install/pe/99_restart_server.rb

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd

