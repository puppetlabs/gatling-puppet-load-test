#!/bin/sh
# This script is used by Jenkins to ensure (as much as we can) that
# the previous installation of Puppet OSS has been completely
# removed so we can install a newer version on the machine.

killall -w puppet || true
rm -rf /usr/lib/ruby/site_ruby/1.8/*
rm -rf /usr/bin/facter
rm -rf /usr/bin/hiera
rm -rf /usr/bin/puppet
rm -rf /usr/bin/extlookup2hiera
rm -rf /opt/puppet-git-repos
rm -rf /etc/puppet
rm -rf /var/lib/puppet