#!/usr/bin/env bash

set -e

echo "

This script will help you get SSL set up for a gatling puppet simulation.
It will retrieve the necessary SSL certs and keys from a representative
agent node, and use them to create a Java keystore file that gatling
can use during the simulation run.  The keystore file will be created
in ./target/ssl.

Here are some assumptions that this program makes.  Please make sure that
they are accurate.

* You have a Puppet master up and running somewhere, and you are preparing
  to run a gatling simulation against that Puppet master.
* You have a Puppet agent node up and running, configured to use the master
  that you are going to run the gatling simulation against.
* You've already done successful agent runs from the agent to the master.
* You have set up a public key so that you can ssh into that agent machine
  as root from this machine.
* You have sbt, java, keytool, and openssl available on this machine.

All that sound correct?  If so, press enter to continue.
PRESS ENTER"
read

echo "


Great.  Now we need to get the necessary SSL files from the agent node.
I'll snag them for you via scp.

Please enter the hostname or IP of the agent machine: "
read -e PE_AGENT

echo "Copying files from $PE_AGENT"

rm -rf ./target/ssl
mkdir -p ./target/ssl
HOST_CERTNAME=`ssh root@${PE_AGENT} "puppet agent --configprint certname"`
HOST_CERT=`ssh root@${PE_AGENT} "puppet agent --configprint hostcert"`
HOST_KEY=`ssh root@${PE_AGENT} "puppet agent --configprint hostprivkey"`
CA_CERT=`ssh root@${PE_AGENT} "puppet agent --configprint localcacert"`

scp root@${PE_AGENT}:${HOST_CERT} ./target/ssl/hostcert.pem
scp root@${PE_AGENT}:${HOST_KEY} ./target/ssl/hostkey.pem
scp root@${PE_AGENT}:${CA_CERT} ./target/ssl/cacert.pem

echo "Copied files.  Generating keystore file for gatling."

cat ./target/ssl/hostcert.pem ./target/ssl/hostkey.pem > ./target/ssl/keystore.pem
echo "puppet" | openssl pkcs12 -export -in ./target/ssl/keystore.pem -out ./target/ssl/keystore.p12 -name ${HOST_CERTNAME} -passout fd:0
keytool -importkeystore -destkeystore ./target/ssl/gatling-keystore.jks -srckeystore ./target/ssl/keystore.p12 -srcstoretype PKCS12 -alias ${HOST_CERTNAME} -deststorepass "puppet" -srcstorepass "puppet"

echo "Keystore successfully generated.  Generating truststore."

keytool -import -alias "CA" -keystore ./target/ssl/gatling-truststore.jks -storepass "puppet" -trustcacerts -file ./target/ssl/cacert.pem -noprompt

echo "Truststore successfully generated."

echo "
Your SSL configuration is now ready.  The simulation runner is pre-configured
(via the file ./config/gatling.conf) to look in the ./target/ssl directory
to find the keystore and truststore that it should use during the simulation.

You should now be able to launch your simulation whenever you are ready!
"
