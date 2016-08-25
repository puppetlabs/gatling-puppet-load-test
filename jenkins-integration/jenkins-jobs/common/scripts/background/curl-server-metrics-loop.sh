#!/usr/bin/env bash

set -x

while true ; do
  curl -sS -w "\n" -k https://localhost:8140/status/v1/services?level=debug >> /var/log/puppetlabs/puppetserver/metrics.json
  # this value was chosen somewhat arbitrarily... but here are some napkin math numbers:
  # * a 2-week long run would be going for 2 * 7 * 24 * 60 = 20610 minutes
  # * if we log metrics every 5 minutes, that's 20610 / 5 = 4122 log entries
  # * each log entry appears to be about 8k, so over a 2 week run this metrics
  #   file would get up to about 32MB, which seems tolerable.
  sleep 300
done
