#!/bin/sh

SCENARIO=$1
SYSTEST_CONFIG=$2
SSH_KEYFILE=$3

export PUPPET_GATLING_SIMULATION_CONFIG=../../simulation-runner/config/scenarios/$SCENARIO
export IS_PE=true
export pe_dist_dir='/opt/enterprise/dists/3.0'
export pe_dep_versions=./config/versions/pe_version
cd puppet-acceptance

./systest.rb \
  --config $SYSTEST_CONFIG \
  --type manual \
  --no-color \
  --xml \
  --debug \
  --preserve-hosts \
  --no-install \
  --keyfile $SSH_KEYFILE \
  --tests ../../simulation-runner/acceptance/setup
