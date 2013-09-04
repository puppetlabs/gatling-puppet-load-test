#!/bin/sh

MASTER_IP=$1

ssh jenkins@ull.delivery.puppetlabs.net 'sudo /usr/bin/cobbler system edit --name='centos6-64-perf02' --netboot-enable=True'

echo "Rebooting the target machine"
ssh root@$MASTER_IP reboot

echo "Sleeping 60 seconds to wait for it to begin rebooting."
date
sleep 60
date

echo "Attempting to reconnect."
while true; do
  echo "Attempting to ssh"
  ssh root@$MASTER_IP "echo SUCCESS" && break
done

echo "Disabling firewall on master"
ssh root@$MASTER_IP "service iptables stop"
ssh root@$MASTER_IP "ping -c 2 neptune.delivery.puppetlabs.net"
