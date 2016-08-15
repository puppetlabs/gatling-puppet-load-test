#!/bin/bash

pushd jenkins-integration
source jenkins-jobs/common/scripts/job-steps/initialize_ruby_env.sh

# This job sets up the following:
# - OPS environments installed on master
# - CatalogZero module added to production environment
#
# Note that we only need the OPS environments installed, we don't need to
# explicitly reference them or use any of their classes; simply having them
# there will exhibit the slow performance behavior we're trying to highlight
# with this job.

# TODO TODO TODO: this should *NOT* be hard-coded in the job template,
#  this is very specific to a given job.

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
jenkins-jobs/common/scripts/ops-deployment/install_ops_modules_snapshot.rb,\
jenkins-jobs/common/scripts/ops-deployment/install_catalog_zero.rb

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd
