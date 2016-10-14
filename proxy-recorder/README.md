These tools are designed to help you capture request/response data from
a Puppet agent run, for use in a Gatling load test simulation.

Prerequisites:

* Java bin dir must be in your path (relies on keytool)
* openssl command-line programs
* Scala's 'sbt' build tool (http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html#installing-sbt)

Once you have these, just run the `launch-gatling-proxy.sh`.  The shell script
is interactive and will walk you through the rest of the process.

Note that in order to take a recording, you'll need a master and an agent that
you can place the proxy between to capture the traffic from an agent run.  The
easiest way, by far, to get a master set up that is configured properly (permissive
authorization rules, required puppet code for catalog compilation, etc.) is to
create a `Jenkinsfile` that describes the perf test you ultimately want to run,
and use Jenkins to run it once.  The framework will perform the provisioning /
PE installation for you, and then you can use that master to capture the proxy
recording.  For more info on this see the
[docs on setting up a dev driver environment](../jenkins-integration/dev).

After the recording is complete, the raw output from the Gatling recorder
needs to be modified a bit to work with the gatling-puppet-load-test framework.
The script should take care of all of this for you, but if something goes wrong
or if you're interested in the gory details, check out
[README-GENERATING-AGENT-SIMULATIONS.md](./README-GENERATING-AGENT-SIMULATIONS.md).
          
  



