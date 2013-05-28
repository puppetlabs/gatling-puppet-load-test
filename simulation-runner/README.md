gatling-puppet-scale-test
=========================

This project is intended to be used in a Jenkins job to run puppet
agent simulations against an existing puppet master, for the purposes
of load testing.

To generate agent simulations, use the shell script in the
`proxy-recorder` folder, and then copy the resulting code
into this project.  It should go in this folder:

    src/main/scala/com/puppetlabs/gatling/node_simulations

You'll need to make some small tweaks to the generated code, as
described in `README-GENERATING-AGENT-SIMULATIONS`.

You'll also need to set up a corresponding configuration file
in `config/nodes`.

Then you may reference your config file in one or more "scenarios",
which are defined in `config/scenarios`.

Once you've defined a scenario, you can run it by just executing
`sbt run` in this directory; you'll be prompted for some
missing environment variables, including one that specifies the
path to the scenario config file.

In Jenkins, you can set up these vars using the `EnvInject` plugin.
For best results, you'll also want to make sure that your jenkins
node has version 1.0.3 or later of the Gatling Jenkins Plugin.
