#!/bin/sh

SCENARIO=$1
SYSTEST_CONFIG=$2
SSH_KEYFILE=$3
SIM_ID=$4
WORKSPACE=$5

export PUPPET_GATLING_SIMULATION_CONFIG=config/scenarios/$SCENARIO
export PUPPET_GATLING_SIM_ID=$SIM_ID

export SBT_FILENAME=$SCENARIO
export SBT_WORKSPACE=$WORKSPACE

bundle exec beaker             \
  --config "$SYSTEST_CONFIG"   \
  --helper beaker/helper.rb    \
  --tests beaker/simulate/run_sbt.rb \
  --preserve-hosts             \
  --collect-perf-data          \
  --no-color                   \
  --xml                        \
  --ntp                        \
  --root-keys                  \
  --repo-proxy                 \
  --log-level debug            \
  --keyfile $SSH_KEYFILE
