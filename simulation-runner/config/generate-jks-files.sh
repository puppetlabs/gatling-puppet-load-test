#!/bin/bash

die () {
    echo >&2 "$@"
    echo "Usage: $0 <pem_dir>"
    echo "   <pem_dir>: a directory full of puppet pems that exists in ./ssl/pems"
    echo "              certnames should be 'puppet-master' and 'puppet-agent'."
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"

pem_dir="./ssl/pems/$1"
[ -d "$pem_dir" ] || die "directory does not exist: $pem_dir"

tmpdir="./tmp/jks-gen/$1"
rm -rf $tmpdir
mkdir -p $tmpdir


cat "$pem_dir/certs/puppet-agent.pem" "$pem_dir/private_keys/puppet-agent.pem" > "$tmpdir/keystore.pem"
echo "puppet" | openssl pkcs12 -export -in "$tmpdir/keystore.pem" -out "$tmpdir/keystore.p12" -name "puppet-agent" -passout fd:0
keytool -importkeystore -destkeystore "$tmpdir/gatling-keystore-$1.jks" -srckeystore "$tmpdir/keystore.p12" -srcstoretype PKCS12 -alias "puppet-agent" -deststorepass "puppet" -srcstorepass "puppet"
keytool -import -alias "CA" -keystore "$tmpdir/gatling-truststore-$1.jks" -storepass "puppet" -trustcacerts -file "$pem_dir/certs/ca.pem" -noprompt
  


