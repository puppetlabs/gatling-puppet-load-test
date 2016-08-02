#!/bin/bash

pushd jenkins-integration
source jenkins-jobs/common/scripts/job-steps/initialize_ruby_env.sh

# This job takes some parameters for an r10k deploy.  It will then
# use r10k to deploy the specified environments from the specified
# control repo to the specified directory on the SUT node.

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
beaker/install/shared/r10k_deploy.rb

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd

