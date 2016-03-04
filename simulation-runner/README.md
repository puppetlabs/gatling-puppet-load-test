gatling-puppet-scale-test
=========================

This project is intended to be used in a Jenkins job to run puppet
agent simulations against an existing puppet master, for the purposes
of load testing.

### NOTES re: hardware configuration

When setting up your Puppet Server or PE SUT to prepare for test runs,
you will want to be careful to make sure that there is going to be enough disk
space available to leave the run going for as long as you intend for it to run.
This is particularly an issue in PE, as the postgres data directory for PuppetDB
and other apps can end up using quite a bit of disk space.

This is particularly tricky on some of the dedicated perf testing hardware that
we are using, because the machines have two disks: a small (~250GB?) SSD that is
mounted at `/`, and a large (1TB) mechanical drive mounted at `/data`.

The easiest way that we've found to deal with this for the time being is, before
you do the PE installation, create a directory called `/data/opt/puppetlabs`, and
then symlink that to `/opt/puppetlabs`.  Afterward, when you install PE, all of the
biggest files / data directories will be set up underneath that symlink, and thus
will reside on the larger disk so that you are less likely to run out of disk space
during your test run.

We intend to automate this as part of the Jenkins jobs that will be used to manage
these runs in the future.

### Generating Agent simulations

To generate agent simulations, use the shell script in the
`proxy-recorder` folder, and then copy the resulting code
into this project.  It should go in this folder:

    src/main/scala/com/puppetlabs/gatling/node_simulations

You'll need to make some small tweaks to the generated code, as
described in [README-GENERATING-AGENT-SIMULATIONS](README-GENERATING-AGENT-SIMULATIONS.md).

You'll also need to set up a corresponding configuration file
in `config/nodes`.

Then you may reference your config file in one or more "scenarios",
which are defined in `config/scenarios`.

### Running simulations

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

In Jenkins, you can set up these vars using the `EnvInject` plugin.
For best results, you'll also want to make sure that your jenkins
node has version 1.0.3 or later of the Gatling Jenkins Plugin.
