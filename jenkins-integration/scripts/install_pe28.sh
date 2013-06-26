#!/bin/sh

SYSTEST_CONFIG=$1
SSH_KEYFILE=$2

export q_puppet_enterpriseconsole_smtp_host=smtp.gmail.com
export q_puppet_enterpriseconsole_smtp_port=587
export q_puppet_enterpriseconsole_smtp_use_tls=y
export q_puppet_enterpriseconsole_smtp_user_auth=y
export q_puppet_enterpriseconsole_smtp_username=dmvrbac@gmail.com
export q_puppet_enterpriseconsole_smtp_password=dmvpassword
export IS_PE=true
export pe_dist_dir='http://neptune.puppetlabs.lan/2.8/ci-ready/'
export pe_version_file='perftesting'
export pe_dep_versions=./config/versions/pe_version

rm -rf pe_acceptance_tests
git clone git@github.com:puppetlabs/pe_acceptance_tests.git
cd pe_acceptance_tests
git checkout pe2.8.1
cd ..

rm -rf puppet-acceptance
git clone git://github.com/puppetlabs/puppet-acceptance.git
cd puppet-acceptance
git checkout pe2.8.1

./systest.rb \
  --config $SYSTEST_CONFIG \
  --type pe \
  --no-color \
  --xml \
  --ntp \
  --root-keys \
  --repo-proxy \
  --snapshot pe \
  --debug \
  --keyfile $SSH_KEYFILE \
  --setup-dir ../pe_acceptance_tests/setup \
  --preserve-hosts \
  --install-only
