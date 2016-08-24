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

# Define the master host to have PE installed.
# The master is assumed to already be available (likely a dedicated blade), so
# we won't try and borrow a VM from the vmpooler.

# NOTE that this beaker task uses the `pe_version` and `pe_family`
# environment variables, which are set in `pipeline.groovy`.
        bundle exec beaker-hostgenerator centos7-64mdca \
        | sed -e "s/centos7-64-1/$SUT_HOST/1" \
        | sed -e 's/hypervisor: vmpooler/hypervisor: none/1' \
        > hosts.yaml

echo "CREATED HOSTS.YAML FILE:"
cat hosts.yaml

# without this set +x, rvm will log 10 gigs of garbage
set +x
popd
