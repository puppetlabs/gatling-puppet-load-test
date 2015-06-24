# beaker
This directory holds beaker scripts that will get run as part of jenkins jobs

**Table of Contents**

  * [install/](#install)
    * [FOSS](#foss)
    * [PE](#pe)
  * [Gatling](#gatling)
    * [10_start_gatling_scenario.rb](#10_start_gatling_scenariorb)
    * [20_start_memory_watcher.rb](#20_start_memory_watcherrb)

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
### 10_start_gatling_scenario.rb
This script starts a gatling scenario, which will run against some SUT. It clones this repo to a hopefully unique directory, `gatling-puppet-load-test_<simulation_id>`, where all the gatling output will be stored.

It needs some environment variables to be set:
* `GATLING_SIMULATION_ID`: An identifier for the run
* `GATLING_SCENARIO`: A gatling scenario file from the `simulation-runner/config/scenarios/` directory. E.g.: `foss375-catalogzero-100.json`
* `GATLING_SUT_HOSTNAME`: The hostname of the machine the scenario should be run against

It is intended to be used at the same time as `20_start_memory_watcher.rb`, and and to differentiate between the gatling driver and the SUT, your beaker hosts file might look something like this:

```yaml
HOSTS:
  wzmg0128dylvv1d:
    platform: el-6-x86_64
    roles:
    - agent
    - sut
  kf58a5eknd06u1s:
    platform: el-6-x86_64
    roles:
    - agent
    - master
    - gatling
```

Note that the first machine has the role `sut`, and the second has the role `gatling`. For this script only the `gatling` role needs to be specified.

### 20_start_memory_watcher.rb
This script starts a simple bash script on the SUT that periodically logs the memory usage of puppetserver. The output is stored in `/root/<simulation_id>_memory_usage/`

It uses some environment variables:
* Required - `GATLING_SIMULATION_ID`: Some identifier for the run
* Optional - `MEMORY_WATCHER_REFRESH`: Interval between memory usage recordings. Defaults to `300`

See the [10_start_gatling_scenario.rb](#10_start_gatling_scenariorb) section for notes on the beaker hosts config.
