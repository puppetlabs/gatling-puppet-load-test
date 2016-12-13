#!/usr/bin/env bash

set -x

MBEANS_FILE=/var/log/puppetlabs/puppetdb/pdb-mbeans.json
METRICS_FILE=/var/log/puppetlabs/puppetdb/pdb-metrics.json.gz
PDB_METRICS_URL=http://localhost:8080/metrics/v1/mbeans

rm -rf "${MBEANS_FILE}"
rm -rf "${METRICS_FILE}"

curl -sS -w "\n" -k "${PDB_METRICS_URL}" | jq  -j 'keys' > "${MBEANS_FILE}"

while true ; do
  curl -sS -H "Content-Type: application/json" -X POST -d @"${MBEANS_FILE}" "${PDB_METRICS_URL}" | gzip -c >> "${METRICS_FILE}"
  sleep 300
done
