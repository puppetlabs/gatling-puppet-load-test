#!/usr/bin/env bash

die() {
  echo "Usage: ${0} <ssh_key_file> <host_fqdn>"
  exit 1
}

keyfile="$1"
sut_host="$2"

if [ "${sut_host}" == "" ]
then
  die
fi

if [ "${keyfile}" == "" ]
then
  die
fi

ssh -i $keyfile root@${sut_host} "mkdir -p ~/.ssh"
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMJNYDV5ZlSvUb2XVjh7iAjvE0k9q2ztWB72AInA30DC/ESmphgTcz14qjJR/ctwPpG/8RvtawHt/jTvTK5IP4kGXsRGqmjAJoDTSZohSGpBFeutCxnfEO3AE/3Z2efhvpvdCVEFCaVnhYPwkoSpvJToZWM15Wxgbz4QfMvtxpy1s/MUpiHPhvpgAYQDys30QXLVP7fI0xqDBPbuNQOdMrK8a0LN9nOCt0rfgyxLYjiHieNgThWodfyt4OitGrWAhaIxNqJ/zMG7M8Tmz/iqCdhe5OwSoUTkbQa/loJ09QihNuLXH5LHYKljeWNdI3jG6cr4NGt59onMVnHF1KnW81Lyf4yue8GoxHTsg9zaNZzYSHzL2uFtZ+2ymNkP9JZ92qiEYN2TIp1UKJ1wJ8pxYBsF/cusNqsdeIwqPUMsJ+rL+eGmXBYpx5YpgU1bOzQXh5xYsSEPTaCAtpMUPew3LrIt1jBGAFMmqteVphZyOu4n/pjVuHqpSz9U1ZqRmotZha62mx9ylwEfWcFlrN+A7AdgcMRyWG2AujyatyObv1ODYQLZq/ZV24Ja06NaxtfozxCIZmRXxiFWF2yEXtxyiCLkBnEaDIRbDjl4l+tAqEphDoBksJMzzohQAq1BuEnRU6PxYBCQxFN5nMY3ZMqHUnWHvL7lPTydoGU3uUT8SD+w== discuss-gatling-puppet-load-test-maintainers@puppet.com' |ssh -i $keyfile root@${sut_host} 'cat >> .ssh/authorized_keys'
