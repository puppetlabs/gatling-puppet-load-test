#!/bin/bash

# Install Docker per the instructions here:
# https://confluence.puppetlabs.com/pages/viewpage.action?pageId=169839939
#

cat > /etc/yum.repos.d/CentOS-Base.repo << 'EOF'
[base]
name=CentOS-$releasever - Base
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os#baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
gpgcheck=0

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras#baseurl=http://mirror.centos.org/centos/$releasever/extras/$basearch/
gpgcheck=0
EOF
yum update -y xfsprogs
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl start docker
yum update -y
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
