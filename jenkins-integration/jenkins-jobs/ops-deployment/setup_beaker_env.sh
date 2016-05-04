#!/usr/bin/env bash

set -e
set -x

which ruby
which bundle
which rvm

bundle install --path vendor/bundle

# Define the master host to have PE 2015.3.1 installed.
# The master is assumed to already be available (likely a dedicated blade), so
# we won't try and borrow a VM from the vmpooler.
pe_version=2015.3.1 pe_family=2015.3.1 \
        bundle exec beaker-hostgenerator centos7-64mdca \
        | sed -e "s/centos7-64-1/$PUPPET_GATLING_MASTER_BASE_URL/1" \
        | sed -e 's/hypervisor: vmpooler/hypervisor: none/1' \
        > hosts.yaml
