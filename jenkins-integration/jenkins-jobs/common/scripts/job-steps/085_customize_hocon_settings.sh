#!/bin/bash

pushd jenkins-integration
source jenkins-jobs/common/scripts/job-steps/initialize_ruby_env.sh

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
beaker/install/shared/85_customize_hocon_settings.rb,\
beaker/install/shared/99_restart_server.rb

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd
