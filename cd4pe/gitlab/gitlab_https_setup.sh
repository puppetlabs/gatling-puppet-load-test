#!/bin/bash

# This script attempts to handle the Gitlab https setup steps described here:
# https://confluence.puppetlabs.com/pages/viewpage.action?pageId=169839939
#

export GITVARDIR=$(docker volume inspect cd4pe_cd4pe_gitlab_etc |grep Mount |awk -F'"' '{ print $4 }')
mkdir "${GITVARDIR}"/ssl
chmod 700 "${GITVARDIR}"/ssl
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -subj "/C=US/ST=Oregon/L=Portland/O=Puppet/CN=gitlab" -keyout "${GITVARDIR}/ssl/gitlab.key" -out "${GITVARDIR}/ssl/gitlab.crt"

echo "external_url 'https://gitlab'" >> "${GITVARDIR}"/gitlab.rb

docker restart cd4pe-gitlab
