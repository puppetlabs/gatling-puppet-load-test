gatling-puppet-agent-capture
============================

This project is designed to help you capture request/response data from
a Puppet agent run, for use in a Gatling load test simulation.

Prerequisites:

* Java bin dir must be in your path (relies on keytool)
* openssl command-line programs
* Scala's 'sbt' build tool (http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html#installing-sbt)

Once you have these, just run the `launch-gatling-proxy.sh`.  The shell script
is interactive and will walk you through the rest of the process.


Output: 

  After the recording is complete, the resulting scenario file must be modified slightly per:
  ../simulation-runner/README-GENERATING-AGENT-SIMULATIONS.md  
          
  



