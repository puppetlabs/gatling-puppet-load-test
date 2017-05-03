# Setting up a Development Environment

This describes how to set up a development environment suitable for working on
the automation for `gatling-puppet-load-test`.  For more info on how the whole
system works, you'll probably want to have read the
[`README.md` in the parent directory](../README.md)
before reading this.

## What you get

The beaker scripts in the `beaker` directory will set up a "driver node", with a
jenkins server and a bootstrap jenkins job, as well as all of the prerequisites
necessary to run a Gatling simulation.  Puppet will be installed and used to manage
all of the above.

## Requirements
This guide assumes you'll be running beaker from your personal machine and you
want to setup a vm pooler machine with the dev environment.

The following are required:
* CentOS 7 VM hostname to be the "driver" machine
* CentOS 7 VM hostname to be the master SUT (only when we run the jenkins jobs)

## Setting up the driver node

To run the beaker script, you need to set up a beaker hosts file that tells beaker
about the machine we're going to use as the driver.  Your options are:

* Edit the `target_machine.yml` file and replace the default hostname `gatling-driver`
  with the hostname of your vmpooler VM, or
* Edit your /etc/hosts file and add an entry for `gatling-driver` that maps to
  the IP of your vmpooler VM, or
* Copy the `target_machine.yml` file to `target_machine_local.yml` and then edit
  it.  `target_machine_local.yml` is in the `.gitignore` file, so you won't have
  to worry about accidentally committing it.

#### Running Beaker

From inside the `dev` directory:
```bash
bundle install --path vendor/bundle
bundle exec beaker \
	--log-level debug \
	--keyfile ~/.ssh/id_rsa-acceptance \
	--hosts ./target_machine.yml \
	--tests beaker/
```

Note that =~/.ssh/id_rsa-acceptance= is the private key used to ssh
into the driver. If using VMPooler VM, this is the VMPooler private
key. If everything goes well, the beaker output should show no errors.

Jenkins should be available on port `8080` of your "driver" machine.  There should
be one or more initial jobs configured; for more detail on what these jobs do,
see the [`README.md` in the parent directory](../README.md).

If you want to poke on the node,  `jenkins-jobs` and `sbt` should be
available at the command line.  However, hopefully most of the work you'll
be interested in doing from here will be driven through Jenkins.

## Setting up the master SUT

During development, the master SUT can be a local VM (e.g. VMWare Fusion), a
VMPooler VM, or a dedicated blade.  For these instructions we'll assume you're
using a vmpooler VM.

#### Using VMPooler VMs

VMPooler VMs should hopefully work pretty much out-of-the-box as SUT nodes.  The
only thing you should need to do is to add a public key that will allow your
driver node to connect to it via beaker, to install PE, etc.

##### Adding driver-compatible public key to SUT node

There's a script in this directory, `add-public-key.sh`, which will do this for you.
(It uses a key that is compatible with the beaker-provisioned driver node if you
followed the steps above.)  To run it:

    ./add-public-key.sh <jenkins-acceptance-keyfile> <vmpooler-sut-node-fqdn>

e.g.:

    ./add-public-key.sh ~/.ssh/id_rsa-acceptance  yw72peu78u7zcxv.delivery.puppetlabs.net

If using a VMPooler VM, this key will likely be the same one used in
the beaker invocation above.

##### SUT vmpooler node - disk space

Depending on how long your gatling run may last, you may end up generating a lot
of data in the PuppetDB database.  You may need to increase the disk space available
to the VMPooler VMs as they are only configured with about 12GB. This will not be
enough disk space for some scenarios.

On a CentOS 7 VM, perform the following steps:

0.  Run `df -h` to see the default disk space. You should see a size of "12G"
    under the `/dev/mapper/<Volume Group>-<Logical Volume>` Filesystem.  This
    number will be updated once we're done adding more disk space.  Note the
    name of the `<Volume Group>` and `<Logical Volume>` since you will need to
    substitute those into various commands below.  For a Filesystem named
    `/dev/mapper/centos-root`, the `<Volume Group>` would be "centos" and the
    `<Logical Volume>` would be "root".
1.  Run `ls /dev/sd*` to see the default disk partitions available.
    You should see something like "/dev/sda /dev/sda1 /dev/sda2 /dev/sdb /dev/sdb2"
    (Once we've added a new disk we should see another result here, like '/dev/sdc')
2.  Curl the VMPooler to add a new disk of the specified size:
    `curl -k -X POST -H X-AUTH-TOKEN:<your_token> --url https://<vmpooler-host>/api/v1/vm/<short-hostname>/disk/18`.
    Here we've added 18GB. See
    https://github.com/puppetlabs/vmpooler/blob/master/API.md#adding-additional-disks
    for more information. This will take several minutes to complete (~10
    minutes).
3.  Wait until the new disk is reflected in the VM status:
    `curl https://<vmpooler-host>/api/v1/vm/<short-hostname>`.
    You should see a section like `"disk": ["+18gb"]` in the output.
4.  Restart the VM with `reboot` and log back in.
5.  Run `ls /dev/sd*` again and we should see the new disk, like '/dev/sdc'.
    The following steps will assume the new disk is named '/dev/sdc'.
6.  Run `pvcreate /dev/sdc` to initialize the volume.
7.  Run `vgextend <Volume Group> /dev/sdc` to add it to the existing volume group.
8.  Run `lvextend /dev/<Volume Group>/<Logical Volume> /dev/sdc`.
9.  Run `xfs_growfs /dev/<Volume Group>/<Logical Volume>`.
10. Run `df -h` and we should now see our updated size of "30G" under the
    `/dev/mapper/<Volume Group>-<Logical Volume>` Filesystem. Done!

The VM should now have increased disk space. Mounting or symlinking the new disk
should not be necessary.

## Metrics

After the test run completes successfuly, metrics are downloaded from
the SUT. Those metrics are available in the archive associated with
the Jenkins job and is downloadable via the Jenkins UI.

## Working on Jobs

Once you have your dev environment up and running, you will mostly be iterating
on the code in the `jenkins-integration/jenkins-jobs` directory in the
`gatling-puppet-load-test` repo.  You may wish to run the bootstrap job on the
driver node periodically to refresh the job that you are working on.  For more
info, read the [`README.md` in the parent directory](../README.md)

## Development Tips

When developing a JJB job or working on the automation, it's useful to run a
local git server instead of cloning from GitHub, which would require that you
constantly push your changes up to GitHub.

This is pretty simple to set up locally, and will require that you temporarily
hard-code your machine's IP address in a couple places.

### Local Git Server

From the parent directory above your local clone of gatling-puppet-load-test,
run the following:

    git daemon --base-path=. --informative-errors --verbose

This will start a foreground process that will serve up any git repository it
finds under `./` to be clonable. The URLs for git commands should look like:

    git://<IP address>/<repo>

For example:

    git clone git://10.0.25.1/gatling-puppet-load-test

*Don't forget to actually commit your changes (likely just as a temporary WIP
commit)!*

You'll need to temporarily change any git references to point to your IP address
instead of GitHub.
