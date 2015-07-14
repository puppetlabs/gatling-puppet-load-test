#!/bin/bash
set -x

export BEAKER_TESTSUITE="${BEAKER_TESTSUITE:-\
beaker/install/foss/10_install_dev_repos.rb,\
beaker/install/foss/20_install_puppet.rb,\
beaker/install/foss/30_install_puppetserver.rb,\
beaker/install/shared/40_clone_test_catalogs.rb,\
beaker/install/shared/50_install_modules.rb,\
beaker/install/foss/60_classify_nodes.rb
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
