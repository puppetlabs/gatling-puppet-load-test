#!/bin/bash

pushd jenkins-integration
source jenkins-jobs/common/scripts/job-steps/initialize_ruby_env.sh

# This file reads a JSON file to find the pids of the background
# scripts running on the SUT, and stops them.

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
beaker/install/shared/stop_sut_background_scripts.rb

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd
