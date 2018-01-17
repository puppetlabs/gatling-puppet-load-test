#!/usr/bin/env bash

echo ""
echo "Setting Up Ruby Environment"
echo ""
source /usr/local/rvm/scripts/rvm
rvm use 2.4.1 || exit 1
rvm list
export GEM_SOURCE=https://artifactory.delivery.puppetlabs.net/artifactory/api/gems/rubygems/
echo -e "\n\n\n"

which ruby
which bundle
