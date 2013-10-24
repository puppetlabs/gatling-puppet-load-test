#!/bin/sh

SYSTEST_CONFIG=$1
SSH_KEYFILE=$2

bundle exec beaker             \
  --hosts $SYSTEST_CONFIG      \
  --no-color                   \
  --xml                        \
  --debug                      \
  --keyfile $SSH_KEYFILE       \
  --tests beaker/restart/pe.rb \
  --preserve-hosts             \
  --no-provision
