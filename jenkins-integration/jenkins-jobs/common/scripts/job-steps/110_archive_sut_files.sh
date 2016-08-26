#!/bin/bash

pushd jenkins-integration
source jenkins-jobs/common/scripts/job-steps/initialize_ruby_env.sh

# This file reads a list of files on the SUT to archive (from an
# environment variable) and copies them to the Jenkins node for archiving.

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
beaker/install/shared/copy_sut_archive_files.rb

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd
