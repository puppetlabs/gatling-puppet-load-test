[![Build Status](https://travis-ci.com/puppetlabs/gatling-puppet-load-test.svg?branch=master)](https://travis-ci.com/puppetlabs/gatling-puppet-load-test)

# Running Performance Test Profiles

#### Table of Contents

1. [Setup](#setup)
1. [Apples to Apples performance tests](#apples-to-apples-performance-tests)
1. [Opsworks performance tests](#opsworks-performance-tests)
1. [Soak performance tests](#soak-performance-tests)
1. [Scale performance tests](#scale-performance-tests)
1. [Acceptance tests](#acceptance-tests)
1. [Other Topics](#other-topics)
    * [BigQuery Data Comparisons](#bigquery-data-comparisons)
    * [Just set up PE and Gatling](#set-up-puppet-enterprise-and-gatling-but-do-not-execute-a-gatling-scenario)
    * [Record a Gatling run](#record-a-gatling-run)
    * [Start a pre-recorded run](#start-a-pre-recorded-run)
    * [Analyze results](#analyze-results)
    * [Abort a test run](#abort-a-test-run)
    * [Generate reports for aborted runs](#generate-reports-for-aborted-runs)


## Setup

**TODO:**

* Define the term 'Apples to Apples'.

* Define the term 'KO'.


### Requirements

In order to run the software in this repo, you need the following
requirements installed.

* [Ruby](https://www.ruby-lang.org/en/)
* [Bundler](https://bundler.io/)
* [OpenJDK](https://openjdk.java.net/)

> **NOTE:** These tasks run for several hours. It is not recommended to run
> them directly from a workstation. You should use a dedicated VM instance to
> control these tasks.

### Environment setup

* Clone the gatling-puppet-load-test repo locally: https://github.com/puppetlabs/gatling-puppet-load-test
* cd into the gatling-puppet-load-test root directory
* Gather the necessary ruby packages by running `bundle install`.


Several infrastructure variants are currently supported by the rake tasks in
this repo.  The specific environment setup steps for each environment are
outlined below.

#### Environment variables

The following environment variables are largely common to the rake tasks shown
below.  They are as follows.

`REF_ARCH`
_(S, L)_ : The desired architecture to be provisioned.  The default is `S`
which designates a
[Standard Reference Architecture](https://puppet.com/docs/pe/latest/choosing_an_architecture.html#monolithic-installation).
Setting this variable to `L` will enable provisioning a
[Large Reference Architecture](https://github.com/reidmv/reidmv-pe_xl/blob/master/documentation/large_deploy.md).
The **Large Reference Architecture** is only supported for a PE installation
and should not be used when deploying a FOSS installation.

`BEAKER_INSTALL_TYPE`
_(git, foss, pe)_ : Determines the underlying path structure of the
puppet install.

`BEAKER_PE_VER`
: The desired PE version to be installed. Must be available within
the `BEAKER_PE_DIR`.

`BEAKER_PE_DIR`
: Path or URL where PE builds are stored for the `BEAKER_PE_VER`.

`PACKAGE_BUILD_VERSION`
: Puppet Server build version to install (FOSS only).

`PUPPET_AGENT_VERSION`
: Puppet Agent build version to install (FOSS only).


It can be helpful to use an env file to manage these environment variables. The file
[config/env/env_setup_2019.0.1](config/env/env_setup_2019.0.1) is provided as an example.

Apply this configuration with the following command:
```
source config/env/env_setup_2019.0.1
```

For more information, see the Beaker documentation on
[beaker environment variables](https://github.com/puppetlabs/beaker/blob/master/docs/concepts/argument_processing_and_precedence.md#environment-variables)


#### For AWS Execution

[Create an AWS access key pair for your AWS account.](https://aws.amazon.com/premiumsupport/knowledge-center/create-access-key/)
Ensure that the key id and secret key are present in an appropriate section of
your `$HOME/.fog` file.  Here is an example: _FIXME: Reference fog website._
```
:default:
  :aws_access_key_id: <access key here>
  :aws_secret_access_key: <secret key here>
```


##### ABS (Always Be Scheduling)

> **NOTE:** This facility is not publicly available and can only be used by
>personnel employed by Puppet the company.

> **NOTE:** AWS instances provided by ABS are automatically destroyed after 24
> hours by the
> [AWS EC2 Reaper](https://github.com/puppetlabs/aws_resource_reaper/tree/master/lambdas/ec2#aws-ec2-reaper).
> The lifetime of these instances can be set to an alternative value by setting
> the desired lifetime with the `ABS_AWS_REAP_TIME` environment variable in
> seconds.

Alternatively, the lifetime can be specified in days via the `ABS_AWS_REAP_DAYS` environment variable.
Setting this variable will override any value set for the `ABS_AWS_REAP_TIME` environment variable.

In either case, the value is ultimately specified in seconds as the `reap_time` parameter of the request to the [`awsdirect` endpoint](https://github.com/puppetlabs/always-be-scheduling#apiv2awsdirect).
This is translated to the `termination_date` tag specified by ABS for the EC2 instance; it can be manually edited in the EC2 console to change the specified value.

The Terminator component of the Reaper runs periodically to ensure that all EC2 instances are terminated if they are past their `termination_date`.

* In order to use an AWS account with access to
  puppetlabs network resources, you need to use
  [ABS](https://github.com/puppetlabs/always-be-scheduling).
  The `performance` task will automatically use ABS to provision two AWS
  instances ('master' and 'metrics') and then execute tests against those
  instances.

* ABS requires a token when making requests. See the
  [Token operations](https://github.com/puppetlabs/always-be-scheduling#token-operations)
  section of the
  [ABS README](https://github.com/puppetlabs/always-be-scheduling/blob/master/README.md)
  for instructions to generate a token.  Once generated, either set the
  `ABS_TOKEN` environment variable with your token or add it to the .fog file in
  your home directory using the abs_token parameter. For example:

```
:default:
  :abs_token: <your abs token>
```

#### For VMPooler Execution

Get an access token for your
[vmpooler](https://github.com/puppetlabs/vmpooler) instance:
```
curl -u jdoe --url https://vmpooler.example.com/api/v1/token
```
For more detailed information, please refer to the
[vmpooler documentation](https://github.com/puppetlabs/vmpooler/blob/master/docs)


## Apples to Apples performance tests

By default, the `performance` rake task will set up a puppet master and a
Gatling driver/metrics node.  It will then kick off a Gatling scenario defined
for apples to apples performance tests.  At the end of the run, the Gatling
results and atop results will be copied back to the test runner.


### Basic usage
You can use the checked-in hosts files
[pe-perf-test.cfg](config/beaker_hosts/pe-perf-test.cfg) or
[foss-perf-test.cfg](config/beaker_hosts/foss-perf-test.cfg).  These are the
defaults for the performance rake task based on the specified
`BEAKER_INSTALL_TYPE` (pe or foss).



#### PE
When testing a PE build, set `BEAKER_INSTALL_TYPE=pe` and provide values for
`BEAKER_PE_VER` and `BEAKER_PE_DIR` environment variables.

Example run
```
export BEAKER_INSTALL_TYPE=pe
export BEAKER_PE_VER=2019.1.0
export BEAKER_PE_DIR=http://enterprise.delivery.puppetlabs.net/archives/releases/2019.1.0
export BASELINE_PE_VER=2018.1.9
export GOOGLE_APPLICATION_CREDENTIALS=mysecret.json  # location of your google json key file

bundle exec rake performance    # (takes about 4 hours)
```


#### FOSS
When testing a FOSS build, set `BEAKER_INSTALL_TYPE=foss` and provide values
for `PACKAGE_BUILD_VERSION` and `PUPPET_AGENT_VERSION` environment variables.

Example run
```
export BEAKER_INSTALL_TYPE=foss
export PACKAGE_BUILD_VERSION=6.3.0
export PUPPET_AGENT_VERSION=6.4.2

bundle exec rake performance    # (takes about 4 hours)
```

### Baseline comparison
In order to have a baseline comparison performed at the end of the test run
set `BASELINE_PE_VER` and `GOOGLE_APPLICATION_CREDENTIALS` in order to
gather the baseline data.  See
[BigQuery Data Comparisons](#bigquery-data-comparisons) for details.


### Rake tasks

`performance`
: Provisions, installs, and runs apples to apples test.

`performance_against_already_provisioned`
: Run tests against an existing set of hosts This task is only intended to be
run against the very latest set of provisioned hosts.

`performance_deprovision_with_abs`
: Destroy ABS hosts.  If the hosts are preserved via Beaker's `preserve_hosts`
setting, then you will need run this task when you are done with the hosts.


### Custom Beaker Configuration
If deployments provided for the **Standard Reference Architecture** and **Large
Reference Architecture** do not meet your needs, create a beaker config file
using one of the configs in [config/beaker_hosts](config/beaker_hosts) as a
template.  Your custom beaker configuration will be used by the
`performance_against_already_provisioned` task if it is available as an
environment variable.

```
export BEAKER_HOSTS=<your beaker_hosts file>
```


## Opsworks performance tests

In order to execute the tests successfully with the `opsworks_performance` rake task, you must set the following environment variables:

* `BEAKER_TESTS=tests/OpsWorks.rb`

* `ABS_AWS_MOM_SIZE` to one of the following:
    * `ABS_AWS_MOM_SIZE=m5.large`
    * `ABS_AWS_MOM_SIZE=c4.xlarge`
    * `ABS_AWS_MOM_SIZE=c4.2xlarge`
    * `ABS_AWS_MOM_SIZE=""`

* `PUPPET_SCALE_CLASS` to one of the following:
    * `PUPPET_SCALE_CLASS=role::by_size::small`
    * `PUPPET_SCALE_CLASS=role::by_size::medium`
    * `PUPPET_SCALE_CLASS=role::by_size::large`
    * `PUPPET_SCALE_CLASS=""`

Execute:
```
bundle exec rake opsworks_performance    # (takes about 1.5 hours)
```


## Soak performance tests

The soak performance test executes a long-running scenario under medium load:
* 14 days
* 600 agents
* `role::by_size::large`

A set of 'soak' rake tasks are provided to handle setup and test execution, allowing nodes to be provisioned as part of the run or as a separate step.
The pre-suite includes tuning of the master via 'puppet infrastructure tune'.

Note that when using the soak rake tasks the `BEAKER_PRESERVE_HOSTS` environment variable is always set to 'true', so you will need to de-provision the test nodes with the `performance_deprovision_with_abs` when your testing is complete.

To ensure AWS instances are not terminated before the test completes and post-test steps are performed the soak rake task sets the reap time to 30 days via the `ABS_AWS_REAP_DAYS` environment variable.
This value can be overridden by specifying a different value for the environment variable.

### To provision and set up nodes as part of the run:

```
bundle exec rake soak
```

### To provision and set up nodes separately:

Run the `soak_setup` rake task to provision and set up the nodes:
```
bundle exec rake soak_setup
```

Then run the 'soak_provisioned' rake task to run the soak test:
```
bundle exec rake soak_provisioned
```

### De-provision the nodes when testing is complete

```
bundle exec rake performance_deprovision_with_abs
```


## Scale performance tests

The scale performance test runs a single repetition of the scenario, increasing the agent count over multiple iterations.
The default Scale scenario starts with 3000 agents and a 30 minute ramp up (corresponding to the default puppet agent check-in interval).
The scenario to run can be specified via the `PUPPET_GATLING_SCALE_SCENARIO` environment variable.

By default the scenario is run for 10 iterations, increasing the agent count by 100 for each iteration.
These values can be specified via the `PUPPET_GATLING_SCALE_ITERATIONS` and `PUPPET_GATLING_SCALE_INCREMENT` environment variables.

After each iteration completes the results are checked and if a KO is found the test is failed.

The results for each iteration are copied to a folder named 'PERF_SCALE{$SCALE_TIMESTAMP}' in `results/scale`.
The sub-directory for each iteration is named based on the scenario, iteration, and number of agents.

As with the Apples to Apples performance tests, to run against a FOSS build, set
`BEAKER_INSTALL_TYPE=foss` and provide values for `PACKAGE_BUILD_VERSION` and
`PUPPET_AGENT_VERSION` environment variables.

In order to execute a Scale performance run:

### Provision, tune, run

A set of 'autoscale' rake tasks are provided to handle setup and scale test execution.
The pre-suite has been updated to include tuning of the master via 'puppet infrastructure tune' for scale tests so this is no longer a manual step.
As with the other test types, nodes can be provisioned as part of the run or as a separate step.

Note that when using the autoscale rake tasks the `BEAKER_PRESERVE_HOSTS` environment variable is always set to 'true', so you will need to de-provision the test nodes with the `performance_deprovision_with_abs` when your testing is complete.

#### To provision nodes as part of the run:

```
bundle exec rake autoscale
```

#### To provision nodes separately:

Run the `autoscale_setup` rake task to provision the nodes:
```
bundle exec rake autoscale_setup
```

Then run the 'autoscale_provisioned' rake task to run the scale test:
```
bundle exec rake autoscale_provisioned
```

#### De-provision the nodes when testing is complete

```
bundle exec rake performance_deprovision_with_abs
```

#### Smaller autoscale tasks

There are additional rake tasks for small and medium autoscale runs to allow testing of the environment and autoscale functionality without waiting for a full run:

`autoscale_provisioned_tiny`
- 1 agent
- 3 iterations
- increment by 1

`autoscale_provisioned_sm`
- 10 agents
- 10 iterations
- increment by 10

`autoscale_provisioned_med`
- 500 agents
- 10 iterations
- increment by 100


## Acceptance tests

You can execute the `acceptance` rake task resulting in a much shorter Gatling
run.  This task runs VMPooler by default.  This is useful for quickly testing
changes to the performance test setup.

The [expected environment variables](#environment-variables) must be set prior
to executing this task.  Additional environment variables can be set
individually or stored in a file and referenced by setting the
`BEAKER_OPTIONS_FILE` environment variable prior to executing this task.  This
repo includes [options files](setup/options), but if you have specific needs
you must craft an options file that meets your needs.  Here is an example.

```
export BEAKER_OPTIONS_FILE='setup/options/options_pe.rb'
```


### Using AWS

To run the task in an AWS environment, you need to set environment variables
for `ABS_OS` and `BEAKER_HOSTS`.  Here is an example:

```
ABS_OS=centos-7-x86-64-west BEAKER_HOSTS=config/beaker_hosts/pe-perf-test.cfg
```



## Other Topics

### BigQuery Data Comparisons

In order to use the BigQuery integration, you will need to perform the following steps:

* Choose to create a new key for the perf-metrics service account - https://console.developers.google.com/iam-admin/serviceaccounts/project?project=perf-metrics&organizationId=635869474587

* Download it and save locally.

* `export GOOGLE_APPLICATION_CREDENTIALS=` setting to the location you have saved the json key file.

If you want to push the metrics to BigQuery at the end of the test run set:

`export PUSH_TO_BIGQUERY=true`

By default this will be set to `false` when running locally and `true` when jobs run in CI.

to the version of PE you want to compare against.

Things to note:

* If `BASELINE_PE_VER` has not been set then the baseline comparison
  assertions in the last test step will not be run (test step will be skipped).

* The string specified for the `BASELINE_PE_VER` must exactly match the string
  specified as the `BEAKER_PE_VER` when that test run was executed. For
  example, if `BEAKER_PE_VER=2018.1.1-rc0-11-g8fbde83` was specified for a
  test run, `BASELINE_PE_VER=2018.1.1-rc0-11-g8fbde83` must be specified in
  the future to use that specific test run as the baseline.

* If `BASELINE_PE_VER` is not found in BigQuery then the last step will error.

* Results are not overwritten, we get the latest result that matches `BASELINE_PE_VER` and the current test name.

* We currently only push up the data we need in order to perform the assertions.

To directly query bigquery:

* Navigate to https://console.cloud.google.com/bigquery?project=perf-metrics

* Execute 'SELECT pe_build_number FROM \`perf-metrics.perf_metrics.atop_metrics\`
GROUP BY pe_build_number'


### Set up Puppet Enterprise and Gatling but do not execute a Gatling scenario

Another use for the performance task would be to record and playback a new scenario either for one-off testing,
or for a new scenario that will be checked in and used.  Additionally, you may just want to execute the setup standalone and then execute the tests later.

* Follow the _Apples to Apples_ instructions, but also `export BEAKER_TESTS=` and `BEAKER_PRESERVE_HOSTS=always` prior to executing the rake task to tell beaker not to execute any tests and preserve the machines.

* Depending on your use case, you can also choose to execute the 'acceptance' task which will run in vmpooler rather than AWS. This is useful when testing/debugging but not for actual performance measurement.


### Record a Gatling run

Assuming that you ran the performance task with no tests, you can follow the directions below to record and then play back a recording manually.

* Ensure you are still SSH'd to the Gatling driver node (metrics) using the -Y argument `ssh -Y root@<driver-host>`

* Execute `cd ~/gatling-puppet-load-test/proxy-recorder`

* Execute `sh ./launch-gatling-proxy.sh`

* Follow the steps from the script

* In the Gatling recorder GUI:
    * Change the 'listening port' to 7000
    * Change 'class name' to a unique value with no spaces such as 'HoytApples' - remember this, as this is the \<GatlingClassName> in subsequent steps.
    * Press start

* Back in the cmd line on the Gatling driver node, press 'enter'

* Copy the command to execute on the agent node

* SSH into the agent node and:  (Ignore instructions from the script)
    * Paste in the command
    * Replace value for --server with the FQDN of the MOM
    * Replace value for --http_proxy_host with the IP address of the Gatling driver node
    * Change the value for --http_proxy_port to 7000
    * Execute the command

* Ensure that traffic was captured (rows should appear in the 'executed events' section of the Gatling recorder GUI)

* Press 'Stop and Save'

* Close the GUI

* On the Gatling driver node, press enter

* Continue to follow the script.
    * When asked for the certname prefix enter any value containing the string 'agent'. For example perf-agent-0
    * When asked for Puppet classes, enter the configuration which defaults to: role::by_size::large
        * You can use a different puppet class by specifying it as the `PUPPET_SCALE_CLASS` environment variable for the `performance_gatling` rake task.


### Start a pre-recorded run

For the following steps, GatlingClassName is the value entered into the ClassName field during the recording step.
From root of the gatling-puppet-load-test source dir on the Gatling driver (metrics):

* First time only:
    * edit /usr/share/sbt/conf/sbtopts and change '-mem' to 2048 (and uncomment)

* For each new simulation:
    * `cd ~/gatling-puppet-load-test/simulation-runner`
    * `export GEM_SOURCE=http://rubygems.delivery.puppetlabs.net`
    * `export SUT_HOST=<MOM_OR_LB_HOSTNAME>.us-west-2.compute.internal`
    * Create a json file containing your settings at config/scenarios/\<GatlingClassName>.json, example here: Gist **FIXME: Broken gist link**

        * Change node_config to \<GatlingClassName>.json (this file should exist in simulation-runner/config/nodes)
    * `export PUPPET_GATLING_SIMULATION_CONFIG=../simulation-runner/config/scenarios/<GatlingClassName>.json`
    * `export PUPPET_GATLING_SIMULATION_ID=<GatlingClassName>`
    * `PUPPET_GATLING_MASTER_BASE_URL=https://$SUT_HOST:8140 sbt run`


### Analyze results

* Gatling results, including HTML visualizations show up in the directory: gatling-puppet-load-test/simulation-runner/results/\<GatlingClassName>-\<epoch_time>/
    * scp them locally and you can view them in your browser.

* atop files containing cpu, mem, disk and network usage overall and broken down per process are available to view on the mom: atop -r /var/log/atop/atop\_\<date>
    * See the atop man file for interactive commands


### Abort a test run

The easiest way to immediately kill a test run is to kill the corresponding Java process on the metrics node. Find the process id with top and then use `kill <PID>`.

### Generate reports for aborted runs

If a Gatling scenario is aborted the reports may not be generated. In this case you can run Gatling in reports-only mode to generate the reports for a previous run (assuming that the hosts have been preserved).
You'll need to specify the name of the folder on the metrics node containing the simulation.log file for the run.
Look in `~/gatling-puppet-load-test/simulation-runner/results` for a folder that starts with 'PerfTestLarge-' followed by the run id and verify that the folder contains a valid (non-empty) simulation.log file.

If you find that the simulation.log file is not being populated during your run you may need to reduce the log buffer size from the 8kb default.
Set `gatling.data.file.bufferSize` in `simulation-runner/gatling.conf` to a smaller value like 256 (this may impact performance).

To run in reports-only mode, run as you normally would against previously provisioned hosts and set the environment variables `PUPPET_GATLING_REPORTS_ONLY=true` and `PUPPET_GATLING_REPORTS_TARGET=<YOUR_RESULT_FOLDER>`.

For example:
```
bundle exec rake performance_against_already_provisioned \
    BEAKER_INSTALL_TYPE=pe \
    BEAKER_PRESERVE_HOSTS=always \
    PUPPET_GATLING_REPORTS_ONLY=true \
    PUPPET_GATLING_REPORTS_TARGET=PerfTestLarge-1524773045554
```

After the run you should see that the report files have been generated within the result folder and copied to your local machine.
