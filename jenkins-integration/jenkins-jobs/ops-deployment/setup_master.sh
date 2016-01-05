#!/bin/bash

# This job sets up the following:
# - PE 2015.3.1 installation on provided master
# - OPS environments installed on master
# - CatalogZero module added to production environment
# - Node classified via NC to have catalog zero module
#
# Note that we only need the OPS environments installed, we don't need to
# explicitly reference them or use any of their classes; simply having them
# there will exhibit the slow performance behavior we're trying to highlight
# with this job.

set -x
set -e

# Setup SSH agent for SSH access to PUPPET_GATLING_MASTER_BASE_URL
eval $(ssh-agent -t 24h -s)
ssh-add ${HOME}/.ssh/id_rsa*

ruby193 bundle install --path vendor/bundle

# Define the master host to have PE 2015.3.1 installed.
# The master is assumed to already be available (likely a dedicated blade), so
# we won't try and borrow a VM from the vmpooler.
pe_version=2015.3.1 pe_family=2015.3.1 \
          ruby193 bundle exec beaker-hostgenerator centos6-64mdca \
          | sed -e "s/centos6-64-1/$PUPPET_GATLING_MASTER_BASE_URL/1" \
          | sed -e 's/hypervisor: vmpooler/hypervisor: none/1' \
          > hosts.yaml

# The order that we're running the phases below is important:
# 1. Install just the catalog zero module(s) and then classify via NC
#    * Having the OPS environments in place before hitting the NC will cause the
#      classification to timeout (or some other problem that is escaping me at
#      the moment). We should get rid of this once the troubles go away.
# 2. After classification, install the OPS environments
#    * This will overwrite the module(s) installed previously
# 3. Install the module(s) again
#    * Additive; won't overwrite the OPS environments
ruby193 bundle exec beaker \
        --config hosts.yaml \
        --load-path lib \
        --log-level debug \
        --no-color \
        --tests \
beaker/install/pe/10_install_pe.rb,\
beaker/install/shared/40_clone_test_catalogs.rb,\
beaker/install/pe/50_install_modules.rb,\
beaker/install/pe/98_sync_codedir.rb,\
beaker/install/pe/60_classify_nodes.rb,\
jenkins-jobs/ops-deployment/install_large_files.rb,\
beaker/install/pe/50_install_modules.rb,\
beaker/install/pe/98_sync_codedir.rb,\
beaker/install/shared/configure_authorization.rb,\
beaker/install/pe/99_restart_server.rb
