#!/bin/bash

set -x
set -e
#
## TODO: this relies on knowledge of the CWD.  Fix it to figure out the path
##  of the currently executing script and use that as the base path so that this
##  script will be more re-usable.
#source jenkins-jobs/ops-deployment/initialize_ruby_env.sh

bundle exec beaker \
        --config hosts.yaml \
        --load-path lib \
        --log-level debug \
        --no-color \
        --tests \
beaker/install/shared/configure_gatling_auth.rb

pushd ../simulation-runner
PUPPET_GATLING_MASTER_BASE_URL=https://$PUPPET_GATLING_MASTER_BASE_URL:8140 sbt run
popd

