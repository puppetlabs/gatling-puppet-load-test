#!/bin/sh

SIM_ID=$1
MASTER=$2
SCENARIO=$3

export PUPPET_GATLING_SIMULATION_ID=$SIM_ID
export PUPPET_GATLING_MASTER_BASE_URL=https://$MASTER:8140
export PUPPET_GATLING_SIMULATION_CONFIG=./config/scenarios/$SCENARIO

cd ../simulation-runner
java -Xss2M -Dsbt.log.noformat=true -jar /home/jenkins/sbt-launch.jar run
