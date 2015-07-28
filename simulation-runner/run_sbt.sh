#!/bin/sh

simulation_id=$1
sut_hostname=$2
scenario=$3

export PUPPET_GATLING_SIMULATION_ID=$simulation_id
export PUPPET_GATLING_MASTER_BASE_URL=https://$sut_hostname:8140
export PUPPET_GATLING_SIMULATION_CONFIG=./config/scenarios/$scenario

sbt run
