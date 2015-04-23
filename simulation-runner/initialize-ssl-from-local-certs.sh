#!/usr/bin/env bash

set -e

die () {
    echo >&2 "$@"
    echo "Usage: $0 <ssl_dir> <certname>"
    echo "   <ssl_dir>: path to a local puppet ssldir"
    echo "   <certname>: the certname that gatling should use to grab pems for client requests"
    exit 1
}

[ "$#" -eq 2 ] || die "2 arguments required, $# provided"

echo "

This script will help you get SSL set up for a gatling puppet simulation.
It assumes that you have a local puppet environment set up, and will
pull certs from your ssldir to create a Java keystore file that gatling
can use during the simulation run.  The keystore file will be created
in ./target/ssl.

Press enter to continue.
PRESS ENTER"
read

SSL_DIR=$1
CERTNAME=$2

echo "


Great.  Now we'll copy the necessary files from the ssldir you specified.

Copying cert files for certname ${CERTNAME} from ${SSL_DIR}."

rm -rf ./target/ssl
mkdir -p ./target/ssl

cp "${SSL_DIR}/certs/${CERTNAME}.pem" ./target/ssl/hostcert.pem
cp "${SSL_DIR}/private_keys/${CERTNAME}.pem" ./target/ssl/hostkey.pem
cp "${SSL_DIR}/certs/ca.pem" ./target/ssl/cacert.pem

echo "Copied files.  Generating keystore file for gatling."

cat ./target/ssl/hostcert.pem ./target/ssl/hostkey.pem > ./target/ssl/keystore.pem
echo "puppet" | openssl pkcs12 -export -in ./target/ssl/keystore.pem -out ./target/ssl/keystore.p12 -name ${CERTNAME} -passout fd:0
keytool -importkeystore -destkeystore ./target/ssl/gatling-keystore.jks -srckeystore ./target/ssl/keystore.p12 -srcstoretype PKCS12 -alias ${CERTNAME} -deststorepass "puppet" -srcstorepass "puppet"

echo "Keystore successfully generated.  Generating truststore."

keytool -import -alias "CA" -keystore ./target/ssl/gatling-truststore.jks -storepass "puppet" -trustcacerts -file ./target/ssl/cacert.pem -noprompt

echo "Truststore successfully generated."

echo "
Your SSL configuration is now ready.  The simulation runner is pre-configured
(via the file ./config/gatling.conf) to look in the ./target/ssl directory
to find the keystore and truststore that it should use during the simulation.

You should now be able to launch your simulation whenever you are ready!
"
