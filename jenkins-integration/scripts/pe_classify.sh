#!/bin/sh

SCENARIO=$1
SYSTEST_CONFIG=$2
SSH_KEYFILE=$3
SIM_ID=$4

export PUPPET_GATLING_SIMULATION_CONFIG=config/scenarios/$SCENARIO
export PUPPET_GATLING_SIM_ID=$SIM_ID

bundle exec beaker            \
  --config $SYSTEST_CONFIG    \
  --no-color                  \
  --xml                       \
  --debug                     \
  --preserve-hosts            \
  --no-provision              \
  --keyfile $SSH_KEYFILE      \
  --helper beaker/helper.rb   \
  --tests beaker/classify/pe
