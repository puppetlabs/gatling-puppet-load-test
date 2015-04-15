#!/bin/bash
# set pe_ver and pe_dist_dir
export pe_dist_dir={pe_dist_dir}
export pe_ver={pe_version}
source /etc/profile.d/rvm.sh

rvm 1.9.3 exec beaker --host pipeline/install_puppet_oss/scripts/configure_machine.cfg --tests pipeline/install_puppet_oss/scripts/beaker_scripts/ --no-provision
