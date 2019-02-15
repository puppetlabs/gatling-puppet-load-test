#!/bin/bash

# This script attempts to handle all the Gitlab control repo setup steps described here:
# https://confluence.puppetlabs.com/pages/viewpage.action?pageId=169839939
#

# TODO: update to use puppetserver_perf_control when 'classifier::allow-config-data' issue is resolved
#repo_url=https://github.com/puppetlabs/puppetlabs-puppetserver_perf_control.git
repo_url=https://github.com/puppetlabs/control-repo.git

docker exec -i cd4pe-gitlab mkdir -p /var/opt/gitlab/git-data/repository-import

docker exec -i cd4pe-gitlab git -C /var/opt/gitlab/git-data/repository-import clone --bare ${repo_url}

docker exec -i cd4pe-gitlab chown -R git:git /var/opt/gitlab/git-data/repository-import

docker exec -i cd4pe-gitlab gitlab-rake gitlab:import:repos['/var/opt/gitlab/git-data/repository-import']
