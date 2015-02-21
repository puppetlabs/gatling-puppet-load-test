#!/usr/bin/env bash

GATLING_CONF=./conf ../../gatling-charts-highcharts-2.0.0-RC3/bin/gatling.sh -sf ./src -bf ./request-bodies
