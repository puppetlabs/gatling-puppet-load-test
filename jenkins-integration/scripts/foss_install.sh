#!/bin/bash
set -x

export BEAKER_TESTSUITE="${BEAKER_TESTSUITE:-beaker/install/foss/}"
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
  --debug
