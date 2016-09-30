gatling-puppet-scale-test
=========================

This project is intended to be used in a Jenkins job to run puppet
agent simulations against an existing puppet master, for the purposes
of load testing.

### Generating Agent simulations

To generate agent simulations, use the shell script in the
[`proxy-recorder` directory](../proxy-recorder).  It should do everything that
you need to get an agent recording ready for use with g-p-l-t.  You should see
the resulting recording available in this directory:

    src/main/scala/com/puppetlabs/gatling/node_simulations

The script will also create a "node configuration" file in the `config/nodes`
directory.  For more information on the file format of these node config files,
see [./config/nodes/README.md](./config/nodes/README.md).

Once you have a recording and a node configuration file, you may reference this
node  in one or more "scenario" config file, which are defined in `config/scenarios`.
These allow you to define scenarios that combine multiple types of agent recordings,
potentially with different amounts of load for each type of agent.  For more
information on these config files, see [./config/scenarios/README.md](./config/scenarios/README.md).

### Running simulations

The easiest way to run a simulation is to let Jenkins do it for you.  Check out
[the docs on setting up a dev driver environment](../jenkins-integration/dev) for
more info.

If for some reason you really need to run the simulation manually, outside of
a Jenkins driver instance, read on for some tips.

### Running simulations the hard way

Before you start a simulation run, you will want to ensure that an truststore
with SSL files for the agent being simulated have been put in place.  To do
this, you can run the `retrieve-agent-ssl-certs.sh` script (no arguments
required) from the directory where this document resides.  The script can obtain
the SSL files from the Puppet agent being simulated and use those to generate
a `./target/ssl/gatling-truststore.jks` file.  Note that if you had not
generated the "gatling-truststore.jks" file prior to starting the simulation
run, you could see the following error message during the run:

~~~~
[info] Running com.puppetlabs.gatling.runner.PuppetGatlingRunner
[info] Simulation com.puppetlabs.gatling.runner.ConfigDrivenSimulation started...
[info] [ERROR] [04/08/2015 17:42:52.501] [GatlingSystem-akka.actor.default-dispatcher-2] [akka://GatlingSystem/user/controller] ./target/ssl/gatling-truststore.jks
[info] java.io.FileNotFoundException: ./target/ssl/gatling-truststore.jks
~~~~

Once you've defined a scenario and have the truststore in place, you can, from
the directory where this document resides, run the scenario by executing
`sbt run`.  Note that `sbt run` will fail if one or more environment variables
that the simulation needs are not defined.  For example, if the
`PUPPET_GATLING_SIMULATION_CONFIG` variable has not been defined, the run will
fail with this error:

~~~~
...
[info] Running com.puppetlabs.gatling.runner.PuppetGatlingRunner
[error] Exception in thread "main" java.lang.ExceptionInInitializerError
[error] 	at com.puppetlabs.gatling.runner.PuppetGatlingRunner$.main(PuppetGatlingRunner.scala:17)
[error] 	at com.puppetlabs.gatling.runner.PuppetGatlingRunner.main(PuppetGatlingRunner.scala)
[error] Caused by: java.lang.IllegalStateException: You must specify the environment variable 'PUPPET_GATLING_SIMULATION_CONFIG'!
...
~~~~

Assuming a valid simulation config file called "sample.json" existed in the
`config/scenarios` directory and a Puppet master were listening at
"myhost.localdomain:8140", the following command line could result in a
successful simulation run:

~~~~
PUPPET_GATLING_SIMULATION_CONFIG="config/scenarios/sample.json" PUPPET_GATLING_SIMULATION_ID=foo PUPPET_GATLING_MASTER_BASE_URL=https://myhost.localdomain:8140 sbt run
~~~~

