#!/bin/sh

SYSTEST_CONFIG=$1
SSH_KEYFILE=$2

bundle exec beaker                                \
  --config $SYSTEST_CONFIG                        \
  --tests ../simulation-runner/acceptance/post    \
  --preserve-hosts                                \
  --no-provision                                  \
  --no-color                                      \
  --xml                                           \
  --debug                                         \
  --keyfile $SSH_KEYFILE
