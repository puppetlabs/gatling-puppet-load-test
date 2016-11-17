#!/usr/bin/env bash

pushd jenkins-integration
source jenkins-jobs/common/scripts/job-steps/initialize_ruby_env.sh

if [ -z "$SUT_HOST" ]; then
    echo "Missing required environment variable SUT_HOST"
    exit 1
fi

set -e
set -x

bundle install --path vendor/bundle

# Need to leave the 'pe_dir' option off of the 'hostgenerator' command line
# in order to allow it to use its default instead.
if [ -n "$pe_dir" ]; then
  PE_DIR_ARGS="--pe_dir ${pe_dir}"
else
  PE_DIR_ARGS=""
fi

# Define the master host to have PE installed.
# The master is assumed to already be available (likely a dedicated blade), so
# we won't try and borrow a VM from the vmpooler.

# NOTE that this beaker task uses the `pe_version` and `pe_family`
# environment variables, which are set in `pipeline.groovy`.

bundle exec beaker-hostgenerator $PE_DIR_ARGS --hypervisor "none" centos7-64mdca{hostname=${SUT_HOST}} > hosts.yaml

echo "CREATED HOSTS.YAML FILE:"
cat hosts.yaml

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd
