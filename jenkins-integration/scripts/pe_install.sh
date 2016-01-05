#!/bin/bash
set -x

# Requires version of PE (AIO-only) to install:
#     pe_dist_dir="http://pe-releases.puppetlabs.lan/x.y.z"
#     pe_dist_dir="http://neptune.puppetlabs.lan/4.0/ci-ready"
#     (optional) pe_ver="4.0.0-rc5-161-g85ecc84"

## TODO Add the r10k_deploy.rb step to the TESTSUITE
##      below once we know how it should interoperate
##      with some of the other steps, like install_hiera
##      and install_modules. SERVER-852
export BEAKER_TESTSUITE="${BEAKER_TESTSUITE:-\
beaker/install/pe/10_install_pe.rb,\
beaker/install/shared/40_clone_test_catalogs.rb,\
beaker/install/shared/50_install_modules.rb,\
beaker/install/pe/60_classify_nodes.rb,\
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
