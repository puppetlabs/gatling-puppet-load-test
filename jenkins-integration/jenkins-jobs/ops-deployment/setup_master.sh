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
ssh-add ${HOME}/.ssh/id_rsa

bundle exec beaker \
        --config hosts.yaml \
        --load-path lib \
        --log-level debug \
        --no-color \
        --tests \
jenkins-jobs/ops-deployment/hack_hostname_into_etc_hosts.rb,\
jenkins-jobs/ops-deployment/disable_firewall.rb,\
beaker/install/pe/10_install_pe.rb,\
jenkins-jobs/ops-deployment/install_large_files.rb,\
jenkins-jobs/ops-deployment/install_catalog_zero.rb,\
beaker/install/pe/98_sync_codedir.rb,\
beaker/install/pe/60_classify_nodes.rb,\
beaker/install/shared/configure_permissive_server_auth.rb,\
beaker/install/pe/99_restart_server.rb


