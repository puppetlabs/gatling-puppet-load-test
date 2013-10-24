#!/bin/sh

SYSTEST_CONFIG=$1
SSH_KEYFILE=$2

export q_puppet_enterpriseconsole_smtp_host=smtp.gmail.com
export q_puppet_enterpriseconsole_smtp_port=587
export q_puppet_enterpriseconsole_smtp_use_tls=y
export q_puppet_enterpriseconsole_smtp_user_auth=y
export q_puppet_enterpriseconsole_smtp_username=dmvrbac@gmail.com
export q_puppet_enterpriseconsole_smtp_password=dmvpassword

bundle exec beaker             \
  --config $SYSTEST_CONFIG     \
  --helper beaker/helper.rb    \
  --tests beaker/install/pe.rb \
  --preserve-hosts             \
  --no-color                   \
  --xml                        \
  --ntp                        \
  --root-keys                  \
  --repo-proxy                 \
  --debug                      \
  --keyfile $SSH_KEYFILE
