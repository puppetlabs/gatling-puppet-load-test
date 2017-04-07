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

bundle exec beaker \
        --config hosts.yaml \
        --type aio \
        --load-path lib \
        --log-level debug \
        --no-color \
        --tests \
beaker/install/shared/install_deps.rb

echo "Finished installing supporting dependencies"

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd


