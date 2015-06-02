#!/bin/sh

SYSTEST_CONFIG=$1
SSH_KEYFILE=$2

bundle exec beaker             \
  --config "$SYSTEST_CONFIG"   \
  --helper beaker/helper.rb    \
  --tests beaker/install/foss/ \
  --preserve-hosts             \
  --no-color                   \
  --xml                        \
  --ntp                        \
  --root-keys                  \
  --repo-proxy                 \
  --debug                      \
  --keyfile $SSH_KEYFILE
