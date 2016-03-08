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

Note that the steps involving preparing the TK auth rules to allow the appropriate access for taking a proxy recording can be a bit tricky; for more info, see [../README_tk_auth.md](../README_tk_auth.md).

Output: 

  After the recording is complete, the resulting scenario file must be modified per:
  [README-GENERATING-AGENT-SIMULATIONS](../simulation-runner/README-GENERATING-AGENT-SIMULATIONS.md).
          
  



