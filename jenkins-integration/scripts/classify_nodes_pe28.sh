#!/bin/sh

SCENARIO=$1
SYSTEST_CONFIG=$2
SSH_KEYFILE=$3
SIM_ID=$4

export PUPPET_GATLING_SIMULATION_CONFIG=../../simulation-runner/config/scenarios/$SCENARIO
export IS_PE=true
export pe_dist_dir='/opt/enterprise/dists/2.8'
export pe_dep_versions=./config/versions/pe_version
export PUPPET_GATLING_SIM_ID=$SIM_ID
cd puppet-acceptance

./systest.rb \
  --config $SYSTEST_CONFIG \
  --type pe \
  --no-color \
  --xml \
  --debug \
  --preserve-hosts \
  --no-install \
  --keyfile $SSH_KEYFILE \
  --helper ../../simulation-runner/acceptance/helper.rb \
  --tests ../../simulation-runner/acceptance/setup
