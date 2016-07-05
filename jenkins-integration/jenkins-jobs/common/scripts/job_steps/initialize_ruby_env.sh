#!/usr/bin/env bash

echo ""
echo "Setting Up Ruby Environment"
echo ""
source /usr/local/rvm/scripts/rvm
rvm use 2.1.6 || exit 1
rvm list
export GEM_SOURCE=http://rubygems.delivery.puppetlabs.net
echo -e "\n\n\n"

which ruby
which bundle