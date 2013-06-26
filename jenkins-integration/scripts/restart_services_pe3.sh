#!/bin/sh

SYSTEST_CONFIG=$1
SSH_KEYFILE=$2

cd puppet-acceptance
./systest.rb \
  --config $SYSTEST_CONFIG \
  --type manual \
  --no-color \
  --xml \
  --no-ntp \
  --debug \
  --keyfile $SSH_KEYFILE \
  --tests ../../simulation-runner/acceptance/post \
  --preserve-hosts \
  --no-install
