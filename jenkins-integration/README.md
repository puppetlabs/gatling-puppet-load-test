## Jenkins Integration for Gatling Perf Testing

### Quick project structure overview

This sub project is divided as:

  * `beaker/`: beaker code that is used to install Puppet/PE.
    Hopefully this stuff doesn't need to be used directly or modified
    very frequently.
  * `Gemfile`: the jenkins integration Ruby dependencies
  * `README.md`: this file
  * `dev/`: instructions and tools for spinning up a development environment
    using vmpooler VMs; you can use this to get a temporary driver node and
    SUT node to use to help with developing perf testing jobs.
  * `jenkins-jobs`: the directory that contains all of the JJB job
    definitions for the performance tests.  The driver node will automatically
    create and update jobs based on the contents of this directory.

### How all this stuff works

The basic premise of this perf testing work is as follows.

#### Crappy Diagram
 
![crappy arch diagram](./puppetserver-perf-infra.png)

[draw.io diagram source](https://drive.google.com/a/puppet.com/file/d/0B8v7HryXOF5NMGVEM0tvNmpTQXM/view?usp=sharing)

#### Driver node and SUT nodes

There is a node that we refer to as the "driver" node.  This machine has
a Jenkins server and all of the tools required to run gplt gatling tests.

Then there are one or more nodes we'll refer to as the "SUT" nodes.  These
nodes will have PE / Puppet Server installed on them, and then the driver
will generate load on them by running the gatling tests.

For "production" testing, where we have a long-lived driver node to retain Jenkins
history, and where we need predictable hardware resources on the SUTs, we'll
run on some dedicated hardware that lives in the SysOps PE/Razor environments.

For development work, when you are just trying to get a new test working, you
can spin up the driver and SUT nodes in vmpooler.

##### Relevant repos containing Puppet code

There are two repos containing Puppet code that is used to manage the infrastructure.
Hopefully, in most circumstances, you'll never need to interact with them directly,
but for posterity, they are:

* [puppetlabs-puppetserver_perf_driver](https://github.com/puppetlabs/puppetlabs-puppetserver_perf_driver)

  This repo contains a puppet module that is used to configure everything we need on the driver
  node (Jenkins, sbt, JJB, lots of ssh keys, and more fun stuff).  There are component classes,
  roles, and profiles here that are used in both the production setup and in vmpooler dev
  environments (see the following sections for more info).

* [puppetlabs-puppetserver_perf_driver_dev_control](https://github.com/puppetlabs/puppetlabs-puppetserver_perf_driver_dev_control)

  This is an r10k control repo.  It is used *only* in development / vmpooler environments, to
  fill in a few gaps for things that are managed by profiles in the puppetlabs-modules repo
  in the production setup (because those profiles are not usable outside of the ops environment.)

##### Production Environment

In the production environment, we have 3 dedicated SUT blades, and one driver blade.
These are all provisioned via Razor.  For details on the razor setup,
see the [docs in the `razor` subdirectory](./razor).

The driver node will have all of our Jenkins history and visualizations of trends
of different jobs over time.  It is managed by Puppet, using a role
in the `puppetlabs-modules` repo.

The SUT nodes are ephemeral.  They are re-provisioned with a fresh CentOS7 install
between runs.  This is accomplished via Razor.

##### Development Environment

If you'd like to play with this stuff on your own throw-away vmpooler VMs,
you can do that by running just a few beaker commands.  These will use
(basically) the same Puppet code that is used in the Ops environment to get
your driver node set up.  For more info on this, see the
[docs in the `dev` subdirectory](./dev).

#### Driver node and JJB Jenkins Jobs

The driver node is seeded with an initial job we will refer to as the
"bootstrap" job.  This job will show up in the Jenkins GUI on the driver node as
`refresh-gplt-jobs`.

##### bootstrap/`refresh-gplt-jobs` job

When this job runs, what it does is to pull down
a copy of the gplt git repo, and then run JJB on the
`jenkins-integration/jenkins-jobs` directory (recursively).  This allows
gplt to be the "source of truth" for all of our long-lived Jenkins jobs,
and means that we can do dev work on new perf test jobs pretty much
exclusively in the gplt repo.  At the time of this writing, you need to
run the `refresh-gplt-jobs` job manually to kick off JJB; however, in the
near future we'll add a github poll to that job so that it will detect new
commits to gplt and update the jobs automatically.

Note that, when doing dev work, you can go into the Jenkins GUI on your
driver node and change the github repo / branch that it is pointing to for gplt.
This will allow you to point it at your own fork/branch while you are testing out
new jobs.

##### perf test jobs

Once the `refresh-gplt-jobs` job has been run once, you'll see some other jobs in
Jenkins based on the `Jenkinsfile`s in the `jenkins-integration/jenkins-jobs/scenarios/*`
directories.  For more info, see the [README.md in the `jenkins-jobs` directory](./jenkins-jobs).