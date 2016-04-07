# Setting up a Development Environment
This describes how to set up a development environment suitable for working on
the automation for `gatling-puppet-load-test`

## What you get
The beaker scripts in the `beaker` directory will set up a machine with a
jenkins server, a copy of this repo (which contains the gatling executables),
`sbt` for running gatling, and an installation of `jenkins-job-builder`
configured to point at the jenkins server. Puppet will be installed to manage
the installation of these things.

## Requirements
This guide assumes you'll be running beaker from your personal machine and you
want to setup a separate machine with the dev environment.

The following are required:
* CentOS 6 VM hostname to be the `jenkins-gatling` machine
* CentOS 6 VM hostname to be the master SUT (only when we run the jenkins jobs)
* `~/.ssh/id_rsa` SSH key for cloning private repos from GitHub
* `~/.ssh/id_rsa-acceptance` SSH key for inter-host communication during runs

To actually run gatling against a SUT, you'll need to set up another machine
with some flavor of puppetserver/PE depending on what you're trying to test.
Running tests isn't covered in this guide though.

It's also important to note that if you want to work on the cobbler provisioning
portion of the automation, it's much more involved. There will be a separate
guide for that at some point.

## Setting up the jenkins/gatling box
To run the beaker script, you must first add an entry to your `hosts` file for
`jenkins-gatling` for the IP of your new system.

Alternatively you can edit `dev/target_machine.yml` and
replace `jenkins-gatling` with the hostname or IP of your system.

You also must add your public key (`~/.ssh/id_rsa.pub`) to the `authorized_keys` on
the `jenkins-gatling` node.

#### Running Beaker

From inside the `dev` directory:
```bash
bundle install --path vendor/bundle
bundle exec beaker \
	--log-level debug \
	--hosts ./target_machine.yml \
	--tests beaker/
```

If everything goes well, the beaker output should show no errors.

Jenkins should be available on port `8080` of the `jenkins-gatling` machine.

`jenkins-jobs` and `sbt` should be available at the command line.

A copy of this repo should be in `~/gatling-puppet-load-test`.

#### Configure sbt on Jenkins

Unfortunately you'll need to tell Jenkins where it can find the sbt jar for
actually running the gatling scenario.

On the `jenkins-gatling:8080` web page, perform the following steps:

1. Click "Manage Jenkins"
2. Click "Configure System"
3. Click "Add Sbt" under the Sbt section
4. Enter "default" for the "Sbt name" (an arbitrary name we'll reference later)
5. Uncheck "Install automatically"
6. Set "sbt launch jar" to "/usr/share/sbt-launcher-packaging/bin/sbt-launch.jar"
7. Click "Save" at the bottom

Jenkins will now know where to find the sbt jar, but individual jobs that use
sbt will now need to be configured to use the "default" sbt installation.

#### Deploying jobs to Jenkins

Going to `jenkins-gatling:8080` in your browser will show you the main Jenkins
page, but there will not be any jobs to run.

In order to deploy the JJB jobs to Jenkins, run the `jenkins-jobs update`
command with a JJB YAML file. For example:
```bash
jenkins-jobs update gatling-puppet-load-test/jenkins-integration/jenkins-jobs/run_gatling_scenario.yml
```

You'll need to configure the job to use our "default" sbt installation now.

1. Click "Configure" on the new job page.
   You should see a Build section, with a "Build using sbt" block with the sbt
   launcher set to "default".
2. Click "Save"

Yes, we just opened a web page, did nothing, and closed it. Welcome to Jenkins.

The job should now be ready to use the sbt plugin for running gatling.

## Setting up the master SUT

During development, the master SUT can be a local VM (e.g. VMWare Fusion), a
VMPooler VM, or a dedicated blade.

#### Using VMPooler VMs

You may need to increase the disk space available to the VMPooler VMs as they
are only configured with about 12GB. This will not be enough disk space for some
scenarios, like the OPS deployment.

On a CentOS 6 VM, perform the following steps:

0.  Run `df -h` to see the default disk space. You should see a size of "12G"
    under '/dev/mapper/VolGroup-lv_root'. This number will be updated once we're
    done adding more disk space.
1.  Run `ls /dev/sd*` to see the default disk partitions available.
    You should see something like "/dev/sda /dev/sda1 /dev/sda2 /dev/sdb /dev/sdb2"
    (Once we've added a new disk we should see another result here, like '/dev/sdc')
2.  Curl the VMPooler to add a new disk of the specified size:
    `curl -k -X POST -H X-AUTH-TOKEN:<your_token> --url https://<vmpooler-host>/api/v1/vm/<short-hostname>/disk/18`
    Here we've added 18GB. See
    https://github.com/puppetlabs/vmpooler/blob/master/API.md#adding-additional-disks
    for more information. This will take several minutes to complete (~10
    minutes).
3.  Wait until the new disk is reflected in the VM status:
    `curl vmpooler/api/v1/vm/$(hostname)`
    You should see a section like `"disk": ["+18gb"]` in the output.
4.  Restart the VM with `reboot` and log back in.
5.  Run `ls /dev/sd*` again and we should see the new disk, like '/dev/sdc'.
    The following steps will assume the new disk is named '/dev/sdc'.
6.  Run `pvcreate /dev/sdc` to initialize the volume
7.  Run `pvdisplay` and we should see our new physical volume '/dev/sdc'.
    Note the "VG Name" value of the other volumes; we'll need to add our new
    volume to this group (likely named "VolGroup").
8.  Run `vgextend VolGroup /dev/sdc` to add it to the existing volume group.
9.  Run `lvextend /dev/VolGroup/lv_root /dev/sdc`
10. Run `resize2fs /dev/VolGroup/lv_root`
11. Run `df -h` and we should now see our updated size of "30G". Done!

The VM should now have increased disk space. Mounting or symlinking the new disk
should not be necessary.

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
instead of GitHub. This should at least include
`dev/40_clone_gatling_puppet_load_test.rb`, but you'll probably want to change
the git url referenced in your JJB job as well.
