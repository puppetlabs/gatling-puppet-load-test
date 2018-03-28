#!/bin/bash

pushd jenkins-integration
source jenkins-jobs/common/scripts/job-steps/initialize_ruby_env.sh

# This job does the following:
# - clones a fork of puppet
# - checks out a ref
# - rsyncs the libdir ontop of the puppet-agent puppet libdir

set -x
set -e

# Setup SSH agent for SSH access to the SUT
eval $(ssh-agent -t 24h -s)
ssh-add ${HOME}/.ssh/id_rsa

# TODO: get rid of references to ops-deployment

bundle exec beaker \
        --config hosts.yaml \
        --load-path lib \
        --log-level debug \
        --no-color \
        --tests \
beaker/install/shared/clone_and_rsync.rb

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd


