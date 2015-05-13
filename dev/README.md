# Setting up a Development Environment
This describes how to set up a development environment suitable for working on
the automation for `gatling-puppet-load-test`

## What you get
The beaker scripts in the `beaker` directory will set up a machine with a
jenkins server, a copy of this repo (which contains the gatling executables),
`sbt` for running gatling, and an installation of `jenkins-job-builder`
configured to point at the jenkins server.

## Requirements
This guide assumes you have a centos-6 machine/VM with:
  * ssh key authentication for the root user (for `beaker`)
  * `puppet` installed and in the `PATH`

This will be your jenkins/gatling box 

To actually run gatling against a SUT, you'll need to set up another machine
with some flavor of puppetserver/PE depending on what you're trying to test.
Running tests isn't covered in this guide though.

It's also important to note that if you want to work on the cobbler provisioning
portion of the automation, it's much more involved. There will be a separate
guide for that at some point.

## Setting up the jenkins/gatling box
To run the beaker script, you must first add an entry to your `hosts` file for `jenkins-gatling` for the IP of your new system.

Alternatively you can edit `dev/beaker/target_machine.yml` and
replace `jenkins-gatling` with the hostname or IP of your system.

#### Running Beaker

From inside the `dev` directory:
```bash
bundle install
bundle exec beaker \
	--log-level debug \
	--hosts beaker/target_machine.yml \
	--tests beaker/
```

If everything goes well, the beaker output should show no errors.

Jenkins should be available on port `8080` of your machine.

`jenkins-jobs` and `sbt` should be available at the command line.

A copy of this repo should be in `~/gatling-puppet-load-test`
