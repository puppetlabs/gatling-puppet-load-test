#!/bin/sh

SYSTEST_CONFIG=$1
SSH_KEYFILE=$2

export q_puppet_enterpriseconsole_smtp_host=smtp.gmail.com
export q_puppet_enterpriseconsole_smtp_port=587
export q_puppet_enterpriseconsole_smtp_use_tls=y
export q_puppet_enterpriseconsole_smtp_user_auth=y
export q_puppet_enterpriseconsole_smtp_username=dmvrbac@gmail.com
export q_puppet_enterpriseconsole_smtp_password=dmvpassword
export pe_dist_dir='http://neptune.delivery.puppetlabs.net/archives/releases/2.8.3'

bundle exec beaker                                          \
  --config $SYSTEST_CONFIG                                  \
  --helper ../simulation-runner/acceptance/helper.rb        \
  --tests ../simulation-runner/acceptance/install           \
  --preserve-hosts                                          \
  --no-color                                                \
  --xml                                                     \
  --ntp                                                     \
  --root-keys                                               \
  --repo-proxy                                              \
  --debug                                                   \
  --keyfile $SSH_KEYFILE
