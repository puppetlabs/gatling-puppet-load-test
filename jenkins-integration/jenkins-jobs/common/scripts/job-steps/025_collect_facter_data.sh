#!/bin/bash

pushd jenkins-integration
source jenkins-jobs/common/scripts/job-steps/initialize_ruby_env.sh

# This job does the following:
# - Collects facter data
# - Collects some basic information about the gatling scenario
# - writes these to a file path that can be found by the puppet-gatling-jenkins
#   plugin after the run

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
beaker/install/shared/collect_facter_and_scenario_data.rb

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd


