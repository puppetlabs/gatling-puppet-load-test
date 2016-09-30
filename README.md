## Welcome to load testing Puppet with Gatling!

This repo contains tools for load testing Puppet Enterprise, Puppet Server, and other components.  It works by building
an existing [open source load testing called Gatling](http://gatling.io), which allows you to record HTTP traffic
and replay it, and then generate reports about the performance of the simulated requests.  We use this to simulate
Puppet agent requests to Puppet Server, but in a full PE installation, since Puppet Server is driving communication
with PuppetDB, the Node Classifier, etc., we end up exercising all of the PE components.

### What's in this repo?

The repo is broken up into three main projects, which can be found in the [`jenkins-integration`](./jenkins-integration),
[`proxy-recorder`](./proxy-recorder), and [`simulation-runner`](./simulation-runner) directories.  Read on for additional
info about each.

#### [`jenkins-integration`](./jenkins-integration)

This directory contains tools and code that can be used to build up a "driver" server, which includes a Jenkins server
pre-configured to run our perf testing jobs, as well as all of the prerequisites required to run gatling and the other
components of the jobs.  The [jenkins-integration/dev](./jenkins-integration/dev) directory contains documentation on
how you can quickly spin up a development server to use for creating / testing new perf testing jobs.

#### [`proxy-recorder`](./proxy-recorder)

This directory contains a helper script that is geared towards making it easy to launch the Gatling recorder, use it to
record traffic between an agent and a master, and then prepare that recording for use in a perf test.

#### [`simulation-runner`](./simulation-runner)

This directory contains all of the existing Gatling recordings we've taken from various kinds of agents.  It also contains
some configuration files that are used by the perf tests, and some helper code that makes it easier to configure the options
about how to use a recording in a perf test: sleep time, number of simulated agents, number of repetitions, etc.