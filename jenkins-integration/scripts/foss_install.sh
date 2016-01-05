#!/bin/bash
set -x

## Requires:
## 1. Version of puppet-agent package to install
##    Can be specified with either:
##    - ENV['PUPPET_BUILD_VERSION']=1.3.0
##    - hosts.yaml#CONFIG#puppet_version: 1.3.0
##
## 2. Version of puppet-server package to install
##    Can be specified with either:
##    - ENV['PUPPETSERVER_BUILD_VERSION']=2.2.1
##    - hosts.yaml#CONFIG#puppetserver_version=1.3.0

if [ -z $BEAKER_CONFIG ]; then
    echo "BEAKER_CONFIG hosts configuration required"
    exit 1
fi

## TODO Add the r10k_deploy.rb step to the TESTSUITE
##      below once we know how it should interoperate
##      with some of the other steps, like install_hiera
##      and install_modules. SERVER-852
export BEAKER_TESTSUITE="${BEAKER_TESTSUITE:-\
beaker/install/foss/10_install_dev_repos.rb,\
beaker/install/foss/20_install_puppet.rb,\
beaker/install/foss/30_install_puppetserver.rb,\
beaker/install/shared/40_clone_test_catalogs.rb,\
beaker/install/shared/50_install_modules.rb,\
beaker/install/foss/60_classify_nodes.rb,\
beaker/install/shared/70_install_hiera.rb
}"
export BEAKER_KEYFILE="~/.ssh/id_rsa-acceptance"
export BEAKER_HELPER="beaker/helper.rb"

bundle install --path vendor/bundle

bundle exec beaker \
  --config $BEAKER_CONFIG \
  --type aio \
  --helper $BEAKER_HELPER \
  --load-path lib \
  --tests $BEAKER_TESTSUITE \
  --keyfile $BEAKER_KEYFILE \
  --preserve-hosts onfail \
  --no-color \
  --debug
