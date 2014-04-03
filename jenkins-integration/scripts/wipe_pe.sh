#!/bin/sh
# This script is used by Jenkins to ensure (as much as we can) that
# the previous installation of Puppet Enterprise has been completely
# removed so we can install a newer version on the machine.

# Run the official uninstaller
# -d    Delete databases
# -p    Purge everything! A full uninstall
# -y    Answer 'yes' to all questions
cd /tmp/$(date +'%Y')-*/puppet-enterprise-*
./puppet-enterprise-uninstaller -d -p -y

# Make sure these directories are gone
cd /tmp/
rm -rf ./$(date +'%Y')-*
rm -rf /etc/puppetlabs/

# Make sure MySQL is gone
yum erase --assumeyes mysql
rm -rf /var/lib/mysql/

# Clean yum repository
yum clean all
