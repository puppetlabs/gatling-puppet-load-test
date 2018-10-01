#!/usr/bin/env bash


set -e

echo "

Here are some assumptions that this program makes.  Please make sure that
they are accurate.

* You have a PE master up and running somewhere.
* You have set up a public key so that you can ssh into that PE master machine
  as root from this machine.
* The PE master has a Trapperkeeper Authorization configuration that allows all connections; for more info on this, see https://github.com/puppetlabs/gatling-puppet-load-test/README_tk_auth.md .
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
Sweet!  Now we're ready to launch the gatling proxy.
When you press enter, we'll launch it as a background process, and
print out some more instructions here.  If you can arrange the windows so
that you can see both this script and the proxy, that'll help.

Press enter to launch the proxy.
PRESS ENTER"
read

# Gatling recorder arguments http://gatling.io/docs/2.0.0-RC2/http/recorder.html
# * pkg (package)
#   Scala package (and directory structure) the generated file will be in
# * of (output-folder)
#   Directory to create the package tree under
# * ihr (infer HTML resources)
#   Disable regrouping of resource requests (agent's wont be doing that)
sbt "run -pkg com.puppetlabs.gatling.node_simulations -of $PWD -ihr false" \
    > gatling-recorder.log &

echo "Proxy launched.

(The proxy GUI will take a while to launch on the first run, as sbt is
downloading all of the gatling binaries.  You can check the file
'gatling-recorder.log' in this directory to see what's going on.)

So now you should see a dialog asking for some information about the simulation
we're going to record.  You can leave most of the fields alone.  Here's the ones
you should define:

* Class Name: some succinct description of what is interesting about this agent;
   e.g. 'LotsOfExportedResources'

* Output folder: path to wherever you want the generated simulation code to go

* Listening port (HTTPS): it's fine to leave this as 8000 if that port is open
   on your machine, but you can change it if you like.  You will need to know
   this value for the next steps.

* Infer html resources?: This should be unchecked by default.  If not, you
   should uncheck it.  Leaving it checked would cause the generated simulation
   code to try to replay groups of requests that look like 'resources', e.g.,
   links from an HTML document, concurrently.  This simulates the behavior that
   a browser would perform to obtain these kinds of resources.  We don't want
   that behavior for a Puppet agent simulation, though, because a real Puppet
   agent will only request 'resources' serially.  For example, any follow up
   file_metadata / file_content requests that an agent would make based on
   content in the catalog would be done one at a time.

Once you've set those, you can click the 'Start' button to start the proxy.
PRESS ENTER"
read

echo "

Now you should see the 'Gatling Recorder - Running...' window, with a bunch
of empty textboxes for request and response data.  Cool.

The last step is to run your puppet agent, pointed at the proxy.  To do that,
simply log in to your agent box and run a command like this:

    puppet agent --test --server=<master hostname or IP> --http_proxy_host=<this machine's hostname or IP> --http_proxy_port=8000

You should see some requests appear in the Gatling proxy window.  Once the
agent run completes, click on the 'Stop & Save' button in Gatling, and then
close the Gatling proxy window.
PRESS ENTER"
read

echo "

Great!  At this point your recording should be completed, which means we
should have one new .scala file (containing the recording data), and one
.txt file (containing the body of the agent's report request) on disk.

The script will now make sure it can find these, so we can move them to
the proper locations and commit the raw files to git before we modify
them to work with the puppet-gatling-load-test framework.
PRESS ENTER"
read

FIND_COMMAND='find ./user-files/bodies -name *.txt'
FIND_COUNT=`${FIND_COMMAND} |wc -l`
if [[ "${FIND_COUNT}" -ne "1" ]]
then
   echo "
ERROR!
Uh-oh, something's gone wrong.  The script can't seem to find the report body;
expected '${FIND_COMMAND}' to return \"1\", but it returned \"${FIND_COUNT}\".
Exiting.
"
    exit 1
fi

REPORT_BODY=`${FIND_COMMAND}`
REPORT_FILENAME=`basename "${REPORT_BODY}"`
REPORT_FINAL_PATH="../simulation-runner/user-files/bodies/${REPORT_FILENAME}"
SIMULATION_NAME=`echo "${REPORT_BODY}" |sed 's/^\.\/user-files\/bodies\///g' |sed 's/_[[:digit:]]*_request\.txt$//g'`

echo "Found report body file at '${REPORT_BODY}'"
echo "Simulation name: '${SIMULATION_NAME}'"

SIMULATION_FILE="../simulation-runner/src/main/scala/com/puppetlabs/gatling/node_simulations/${SIMULATION_NAME}.scala"

if [ -f ${SIMULATION_FILE} ]
then
    echo "Found simulation file: '${SIMULATION_FILE}'"
else
    echo "ERROR!  Could not find simulation file '${SIMULATION_FILE}'!  Exiting."
    exit 1
fi

echo "Moving report body file to correct directory."
mv ${REPORT_BODY} ${REPORT_FINAL_PATH}

echo "

OK.  Found the required output files from the recorder and moved them to the
appropriate locations.  Now we'll run our post-processing script that converts the recording
for use with gatling-puppet-load-test.
PRESS ENTER"
read

./process_gatling_recording.rb ${SIMULATION_FILE}
mv ${REPORT_FINAL_PATH}.new ${REPORT_FINAL_PATH}
mv ${SIMULATION_FILE}.new ${SIMULATION_FILE}

echo "
Done!  The recording has been modified successfully.
"

