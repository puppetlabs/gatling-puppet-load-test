#!/bin/bash

pushd jenkins-integration
source jenkins-jobs/common/scripts/job-steps/initialize_ruby_env.sh

# This job sets up the following:
# - local keystore file that gatling can use to talk to the SUT
# - executes gatling simulation

if [ -z "$PUPPET_GATLING_SIMULATION_CONFIG" ]; then
    echo "Missing required environment variable PUPPET_GATLING_SIMULATION_CONFIG"
    exit 1
fi

if [ -z "$PUPPET_GATLING_SIMULATION_ID" ]; then
    echo "Missing required environment variable PUPPET_GATLING_SIMULATION_ID"
    exit 1
fi

set -x
set -e

bundle exec beaker \
        --config hosts.yaml \
        --load-path lib \
        --log-level debug \
        --no-color \
        --tests \
beaker/install/shared/configure_gatling_auth.rb


# without this set +x, rvm will log 10 gigs of garbage
set +x
popd
pushd simulation-runner

set -x

echo "SUT_HOST IS: '${SUT_HOST}'"

PUPPET_GATLING_MASTER_BASE_URL=https://$SUT_HOST:8140 sbt run
# without this set +x, rvm will log 10 gigs of garbage
set +x
popd
