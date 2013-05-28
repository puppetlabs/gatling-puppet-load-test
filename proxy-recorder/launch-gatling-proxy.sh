#!/usr/bin/env bash

set -e

echo "

So you'd like to capture a puppet agent run, eh?


Here are some assumptions that this program makes.  Please make sure that
they are accurate.

* You have a PE master up and running somewhere.
* You have set up a public key so that you can ssh into that PE master machine
  as root from this machine.
* The PE master has an auth.conf file that allows all connections; e.g. you
  can copy the file `conf/auth.conf` from this project to the puppet
  config dir on your PE master.
* You have a PE agent up and running somewhere, and you'd like to capture
  an agent run from it for use in future Gatling scale tests.
* You have classified this PE agent node the way you want it to be classified,
  set up and signed the certs, and you've successfully completed an agent against
  the aforementioned PE master.
* You have sbt, java, keytool, and openssl available on this machine.

All that sound correct?  If so, press enter to continue.
PRESS ENTER"
read

echo "
The first thing that we need to set up an SSL cert for the gatling proxy.
To do this, we're going to need some of the .pem files from the PE master.
I'll snag them for you via scp.

Please enter the hostname or IP of the PE master machine: "
read -e PE_MASTER

echo "Copying files from $PE_MASTER."

rm -rf ./target/tmp/ssl
mkdir -p ./target/tmp/ssl
HOST_CERTNAME=`ssh root@${PE_MASTER} "puppet master --configprint certname"`
HOST_CERT=`ssh root@${PE_MASTER} "puppet master --configprint hostcert"`
HOST_KEY=`ssh root@${PE_MASTER} "puppet master --configprint hostprivkey"`

scp root@${PE_MASTER}:${HOST_CERT} ./target/tmp/ssl/hostcert.pem
scp root@${PE_MASTER}:${HOST_KEY} ./target/tmp/ssl/hostkey.pem

echo "Copied files.  Generating keystore file for gatling."
cat ./target/tmp/ssl/hostcert.pem ./target/tmp/ssl/hostkey.pem > ./target/tmp/ssl/keystore.pem
echo "puppet" | openssl pkcs12 -export -in ./target/tmp/ssl/keystore.pem -out ./target/tmp/ssl/keystore.p12 -name ${HOST_CERTNAME} -passout fd:0
keytool -importkeystore -destkeystore ./target/tmp/ssl/gatling-proxy-keystore.jks -srckeystore ./target/tmp/ssl/keystore.p12 -srcstoretype PKCS12 -alias ${HOST_CERTNAME} -deststorepass "puppet" -srcstorepass "puppet"

echo "Keystore successfully generated."

echo "
Sweet!  Things are going swimmingly.  Now we're ready to launch the gatling
proxy.  When you press enter, we'll launch it as a background process, and
print out some more instructions here.  If you can arrange the windows so
that you can see both this script and the proxy, that'll help.

Press enter to launch the proxy.
PRESS ENTER"
read

sbt "run -pkg com.puppetlabs.gatling.simulation" > gatling-recorder.log &

echo "Proxy launched.

(The proxy GUI will take a while to launch on the first run, as sbt is downloading all of the gatling binaries.  You can check the file `gatling-recorder.log` in this directory to see what's going on.)

So now you should see a dialog asking for some information about the simulation
we're going to record.  You can leave most of the fields alone.  Here's the ones
you should define:

* Class Name: some succinct description of what is interesting about this agent;
   e.g. 'LotsOfExportedResources'

* Output folder: path to wherever you want the generated simulation code to go

* Listening port (HTTPS): it's fine to leave this as 8001 if that port is open
   on your machine, but you can change it if you like.  you will need to know
   this value for the next steps.

Once you've set those, you can click the 'Start' button to start the proxy.
PRESS ENTER"
read

echo "

Now you should see the 'Gatling Recorder - Running...' window, with a bunch
of empty textboxes for request and response data.  Cool.

The last step is to run your puppet agent, pointed at the proxy.  To do that,
simply log in to your agent box and run a command like this:

    puppet agent --test --http_proxy_host=<this machine's hostname or IP> --http_proxy_port=8001

You should see some requests appear in the Gatling proxy window.  Once the
agent run completes, click on the 'Stop & Save' button in Gatling, and then
close the Gatling proxy window.
PRESS ENTER"
read

echo "
All done!  You should now have a .scala file in your output directory that
contains everything that we need in order to simulate this node in a scale test.

The next step is to take that scala file and hack it up just a tiny bit
so that it's compatible with the gatling-puppet-scale-test project.  Head
on over to that project for more info.  Good luck!"
