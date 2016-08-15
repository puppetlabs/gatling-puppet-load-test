TODO: maybe move these into jenkins-jobs/common/scripts/beaker, closer to the
other scripts

# beaker
This directory holds beaker scripts that will get run as part of jenkins jobs.

If you are running any of the existing JJB jobs, or if you copy/paste them as a
template, you may not need to worry about any of the details below.  But if you
need to dig deeper into how Puppet/PE are getting installed, read on.

**Table of Contents**

  * [install/](#install)
    * [FOSS](#foss)
    * [PE](#pe)
  * [Gatling](#gatling)
    * [10_start_memory_watcher.rb](#20_start_memory_watcherrb)

## install/
The `install` directory has scripts to install FOSS puppet and PE

### FOSS
Running the FOSS installer requires a couple things:
* puppetserver version: Supplied through the beaker hosts config option `puppetserver_version`, or the
  `PUPPETSERVER_BUILD_VERSION` environment variable
* puppet-agent version: Supplied through the beaker hosts config option `puppet_version`, or the
  `PUPPET_BUILD_VERSION` environment variable

These build versions should be available on the internal builds server

For example, you can either export the variables:
```bash
export PUPPETSERVER_BUILD_VERSION=2.0.0
export PUPPET_BUILD_VERSION=1.1.0
```

or specify them in a beaker host file:
```yaml
HOSTS:
  centos_box:
    platform: el-6-x86_64
    roles:
    - agent
    - master
    - database
CONFIG:
    puppetserver_version: 2.0.0
    puppet_version: 1.1.0
```

Environment variables take precedence over beaker host files

### PE
When running the PE installer, two options can be set:
* PE dist dir: Where to find the PE packages. Supplied through the beaker hosts config option `pe_dir`, or the
  `pe_dist_dir` environment variable
* PE version: Supplied through the beaker hosts config option `pe_ver`, or the
  `pe_ver` environment variable

You must at least set the PE dist dir. If `pe_ver` isn't set, it will install the latest version at the location provided by the dist dir.

## gatling/
### 10_start_memory_watcher.rb
This script starts a simple bash script on the SUT that periodically logs the memory usage of puppetserver. The output is stored in `/root/<simulation_id>_memory_usage/`

It uses some environment variables:
* Required - `GATLING_SIMULATION_ID`: Some identifier for the run
* Optional - `MEMORY_WATCHER_REFRESH`: Interval between memory usage recordings. Defaults to `300`

The beaker hosts file might look something like this

```yaml
HOSTS:
  wzmg0128dylvv1d:
    platform: el-6-x86_64
    roles:
    - master
    - agent
```

The script uses the `master` role to determine which machine is the SUT

### 20_run_sbt.rb
This script runs `sbt run` inside of the `simulation-runner/` dir on the gatling machine.

The `gatling` role must be applied to the machine in the beaker config file.

It uses some required environment variables:
* `GATLING_SIMULATION_ID`: Some identifier for the run
* `GATLING_SCENARIO`: JSON scenario file
* `GATLING_SUT_HOSTNAME`: Hostname of the puppetserver SUT
* `SBT_WORKSPACE`: The directory the `gatling-puppet-load-test` will be cloned into. If this script is running as part of a jenkins job, it'll be the jenkins workspace most likely.
