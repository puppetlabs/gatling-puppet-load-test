# Puppet Server Perf Testing - Razor Configuration

This directory contains some files and a script that can be used to set up
Razor policies for managing the blades that are used for Puppet Server perf
testing.

We have 4 blades allocated for our perf testing.  At the time of this writing,
the hostnames are:

* puppetserver-perf-sut54.delivery.puppetlabs.net
* puppetserver-perf-sut56.delivery.puppetlabs.net
* puppetserver-perf-sut57.delivery.puppetlabs.net
* puppetserver-perf-driver55.delivery.puppetlabs.net

More details on the hardware can be found [here](https://confluence.puppetlabs.com/display/PERF/Hardware+Assets).

The three SUT boxes are intended to be where we install and run PE.  These nodes
will need to have their operating systems wiped and re-installed frequently to
ensure that we get clean data from run to run.  The "driver" box is where we
will run Jenkins and Gatling to drive the perf tests.

To make sure that this environment is reproducible and to make it easy to get
the operating systems re-installed, we are using the SysOps team's razor instance,
along with their Puppet modules, to manage the nodes.

Docs on the Ops razor instance can be found [here](https://confluence.puppetlabs.com/display/OPS/Razor).

There are four concepts in Razor that are relevant here:

* brokers
* tasks
* tags
* policies

The brokers and tasks are managed via the Ops puppet modules (see
`site/profile/manifests/razor.pp`).  The files in this directory can be used to
manage the more dynamic objects (tags, policies) that are defined in the razor
database; presumably this stuff should never be needed unless there was some
kind of catastrophic failure on the Ops razor instance, but I wanted it to be
automated as much as possible for posterity.

Here is some more info about what each of the object types are used for:

## Brokers

The brokers are used to specify bootstrapping actions that should occur once,
immediately after the node is provisioned.  This is typically used to do things like
install Puppet and configure it to know where its master is.

Brokers have two pieces: a "broker type", which is some files on disk that specify
the behavior, and a "broker", which is an object in the razor DB that we need to
create via the razor CLI.

The files corresponding to the "broker types" are managed by Puppet; see the ops
modules.  The broker object that goes into the Razor database can be represented
as JSON; it's in the `*-broker.json` file in this directory.

### Broker for the `driver` node

The `driver` node uses a broker called `pe`.  This broker was set up by ops and
will handle the work of automatically bootstrapping a Puppet agent that is
configured to talk to their PE master.

Note that whenever this box is reprovisioned, it will end up creating a new
certificate, and we will need to work with the Ops team to get the old certificate
removed and the new certificate signed.

Hopefully this box will be failry stable, and we won't need to re-provision it
unless something big and crazy happens.

### Broker for the `SUT` nodes

These nodes are going to have their OS's wiped regularly, and then they are going
to have PE installed on them.  For that reason, we don't want to use a `puppet`
broker, because we'd have conflicts between the version of Puppet that the broker
installed, and the version we were trying to test.

We want something close to a `noop` broker for these boxes, but there are at least
a few minor tasks we need to do at provisioning time.  For example, we need to
add a public key that will allow the `driver` node to do beaker-y things to these
SUT nodes.  To that end, I've created a custom broker called `puppetserver-perf-sut`
(creative name, I know).  For more details on that, your best bet is probably
just to go look at the puppet code in the Ops module.



## Tasks

Tasks are used for actually installing the operating system on the nodes.  Razor
comes with some default ones, like centos 6 and 7, but you can define your own
if you need to use an operating system that Razor doesn't support out of the box,
or if you need to customize the default ones that come with Razor.

For the tasks we're using, the tasks are just represented as files on disk.  There
is nothing that we need to put into the Razor database for these.

### Task for the `driver` node

None at this time.  We're just using the standard Cent7 task that ships with razor
and it seems sufficient so far.

### Task for the `SUT` nodes

We need a custom kickstart file for the SUT nodes, in order to configure their
disks properly.  The three SUT nodes each have one small-ish SSD and one larger
mechanical drive.  By default, the Razor kickstart file would combine these into
one logical lvm volume, meaning that we'd have no way of knowing which files were
ending up on the SSD vs. the mechanical drive from run to run.  It seems safer to
go ahead and treat the drives as separate partitions with different mount points
so that we can control which files we put where and ensure a consistent hardware
setup from run to run.

To that end, we have a task called `puppetserver-sut-centos/7` that overrides
the default razor kickstart file for cent7 and provides our custom disk configuration.
For more information on this, see the Puppet code in the Ops module.

### Tags

Tags are a more ephemeral object in Razor; they exist only in the Razor database and
aren't tied to any files on disk (like brokers and tasks are).

When a node first boots via razor, it runs facter in a microkernel and sends the
fact data up to the razor server.  Tags allow you to express a PuppetDB-like query
against these facts to identify and group nodes.  We have two tags, `puppetserver-perf-driver`
and `puppetserver-perf-sut`.  At the time of this writing, these tags just have
the mac addresses of the appropriate blades hard-coded, and we can use that information
to identify the nodes and decide what to do with them.

Tags in razor can be represented (and added to the database) via JSON; see the
two `*-tag.json` files in this directory.

### Policies

Policies are used to map nodes (identified via tags) to brokers and tasks.  So,
we have two policies:

* `puppetserver-perf-sut`, which maps the corresponding tag to our special SUT
  broker and our Cent7 task with the custom kickstart file.
* `puppetserver-perf-driver`, which maps the corresponding tag to the `pe` broker,
  and to the default Cent7 task.

These can also be represented as JSON - see the `*-policy.json` files in this
directory.

## Tying it all together

* The "broker types" and tasks are represented as files on disk, and thus they are
  created as a result of the fact that Puppet is managing the appropriate files
  on the Ops razor server (see the Ops puppet modules for more info).
* The brokers, tags, and policies need to be created from the CLI or Razor Web API.
  To that end, there is a script provided in this directory that will take care of it for you:

    ./ensure_razor_objects.sh

  This script tries to be idempotent, so it'll attempt to drop any of the tag/policy
  objects, etc., if they exist, and then recreate them.

Again, hopefully this script will never need to be used, but in the event of
a catastrophic failure on the Ops razor server, or if we need to migrate to a new
razor instance at some point, this script should take care of the dirty work.
