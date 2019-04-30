# SLV Test Environment Setup

#### Table of Contents

- [Background](#background)
- [Environment setup](#environment-setup)
  * [Ruby version](#ruby-version)
  * [Gem management](#gem-management)
- [Test runner](#test-runner)
  * [Specifications](#specifications)
  * [p9_instance_setup](#p9_instance_setup)
- [## Test setup and execution](#test-setup-and-execution)
  * [GPLT instances](#gplt-instances)
  * [Utility scripts](#utility-scripts)
  * [Setting up a new instance](#setting-up-a-new-instance)
- [Test results](#test-results)
  * [Gatling results](#gatling-results)
  * [Puppet Metrics Collector / Viewer](#puppet-metrics-collector-/-viewer)
- [Troubleshooting](#troubleshooting)
  * [Log files](#log-files)

## Background
This document originated as an overview of the SLV team workflow for setting up a gatling-puppet-load-test test environment, executing the various test types, reviewing the test results, and troubleshooting issues.
The intent is to give new team members a step-by-step guide for using gatling-puppet-load-test with explicit instructions on environment configuration parameters (TODO: reword).

## Environment setup

### Ruby version
When running locally, use [rbenv](https://github.com/rbenv/rbenv) to set up a Ruby environment. 
We’re currently using version 2.3.0 on Jenkins and with rbenv in the [p9_instance_setup].

### Gem management
* Use bundler to install dependencies.
* The following aliases provide helpful shortcuts for common commands:
```
alias binstall='bundle install --path vendor/bundle'
alias be='bundle exec'
alias brt='bundle exec rake -T'
```

## Test runner
It is best to use a dedicated Platform9 host as a test runner for gatling-puppet-load-test. 
Test runs can take a minimum of several hours and any interruption will cause the test to abort.
By using [tmux](https://en.wikipedia.org/wiki/Tmux) on a dedicated test runner, you can connect to a session, start a test run, and then disconnect while the test continues to run.
 
### Specifications
Set up a P9 instance per the [Platform9 User Guide in Confluence](https://confluence.puppetlabs.com/pages/viewpage.action?spaceKey=SRE&title=Platform9+User+Guide#Platform9UserGuide-HowdoIcreateanewinstance?).
* Select the ‘centos_7_x86_64’ image.
* Specify a 100 GB volume (or whatever seems appropriate for your needs).
* Select the ‘vol.medium’ flavor.

Set up aliases to SSH directly to the box and a default tmux session; for example:
```
alias gplt92='ssh centos@10.234.1.190'
alias gplt902='ssh centos@10.234.1.190 -t tmux a -t default’
```

### p9_instance_setup
[p9_instance_setup](https://github.com/RandellP/p9_instance_setup) is a module containing a Bolt plan that will "configure a platform9 instance with the needed software to be able to run puppet perf simulations."
Follow the instructions in the [README.md](https://github.com/RandellP/p9_instance_setup/blob/master/README.md) file to install the module and run the provided Bolt plan.

## Test setup and execution
### GPLT instances
It is possible to run more than one performance test simultaneously from a single test runner since the Gatling run actually takes place on the 'metrics' host.
However, each test run must use a separate instance of gatling-puppet-load-test since a single instance does not support multiple simultaneous test runs.
The currently recommended best practice is to create directory in your test user's home such as 'gatling' or 'gplt'.
Within that directory create separate parent directories for each instance with a unique name based on the testing use-case or Jira ticket (i.e. ‘slv-demo’, ‘slv-321a’, etc…).

### Utility scripts
The [util/p9](util/p9) directory contains a set of utility scripts for cloning the gatling-puppet-load-test repo, backing up the current instance, copying reports to nginx, etc...
The scripts are designed to work from a parent directory that will contain an instance of the gatling-puppet-load-test repo with the default name.
The easiest way to get started with the scripts is to copy the 'p9' directory to the test runner and create a copy of it for each new instance.

These scripts are a work-in-progress and will eventually be converted into Bolt tasks with more extensive documentation.
Using the scripts is not required but hopefully you find that they support the common workflows and reduce the manual effort of test execution and reporting.

### Setting up a new instance
These instructions assume that you're using the utility scripts described above and naming the instance 'slv-demo':
* Create a new parent directory on your test runner named 'slv-demo' as a copy of the 'p9' directory:
```
cp -r p9 slv-demo
```

* If you’ll be using this gplt instance regularly it can be helpful to create a separate tmux session and corresponding local alias making it easy to ssh into the workspace as you left it.
One the test runner:
```
tmux new -s slv-demo
```

Local alias: 
```
alias slv-demo='ssh {TEST_USER}@{P9_HOST_IP} -t tmux a -t slv-demo’

```

* Clone the repo into the new parent directory using the `clone` script: 
```
./clone
```

* Navigate into the `gatling-puppet-load-test` directory:
```
cd gatling-puppet-load-test
```

* Install the dependencies using bundler; install to the ‘vendor/bundle’ directory to avoid conflicts:
```
bundle install --path vendor/bundle
```

Set the required environment variables with the provided environment setup file (or set them manually): 
```
source config/env/env_setup_2019.0.1
```

* Run the appropriate rake task for the desired test type:
Performance: 
```
be rake performance
```
  
Scale: 
```
be rake autoscale
```
  
## Test results

### Gatling results
#### nginx
Since the Gatling report is web-based you’ll want to make the result files accessible to a web server; p9_instance_setup handily includes nginx.

In order to navigate the directory structure, add the autolist option to the top level location section in `/etc/nginx/conf.d/default.conf`:
```
...
    location / {
        autoindex on; # added
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
...

```

It is often useful to copy the desired result folders to the nginx directory rather than serving the files from the gplt directory or linking to them in place. 
This way you can remove the working instance directory when you’re done testing and preserve the results. 
Several of the utility scripts described above help make this easier:

TODO: examples

##### Performance
* plist: List the result folders in the ‘gatling-puppet-load-test/results/perf’ directory
* pshow: List the contents of the specified result folder
* pres: Copy the specified result folder to the specified nginx directory (default is ‘slv’)

##### Scale
* slist: List the result folders in the ‘gatling-puppet-load-test/results/perf’ directory
* slog: View the tests-run.log file for the specified scale run
* sshow: List the contents of the specified result folder
* sres: Copy the specified result folder to the specified nginx directory (default is ‘slv’)

It can be helpful to make a copy of the `sres` or `pres` script with a destination that matches the name of the parent directory. 
This makes it easy to navigate the directory structure and find the desired results.

### Puppet Metrics Collector / Viewer
The scale tests copy the data from the puppet metrics collector into the results directory for each iteration and a parent directory for the entire test run.
p9_instance_setup includes puppet-metrics-viewer which can be used to view the data via Grafana.

For a scale run named ‘PERF_SCALE_1555545283’:
```
ruby /home/centos/puppet-metrics-viewer/json2graphite.rb --pattern '/home/centos/gplt/321a/gatling-puppet-load-test/results/scale/PERF_SCALE_1555545283/puppet-metrics-collector/**/*.json' --convert-to influxdb --netcat localhost --influx-db puppet_metrics --server-tag slv-321a-PERF_SCALE_1555545283
```

The `metrics` script in the template folder makes this process easier:
```
./metrics PERF_SCALE_1555545283
```

* Once the data has been imported, navigate to the Grafana instance on the test runner: http://10.234.1.190:3000
* Login with admin / admin.
* Select the ‘Archive Puppetserver Performance’ template.
* Select the server tag specified above: slv-321a-PERF_SCALE_1555545283
* Zoom out to locate the test run, then zoom in to view it

## Troubleshooting
### Log files
Log files for the latest run can be found via the log/latest link which points to the most recently created log directory in log/pe-perf-test.cfg. 
The log directories are named with a timestamp (e.g. 2019-04-16_12_01_30)

#### hosts_preserved.yml
If host preservation is specified via the `BEAKER_PRESERVE_HOSTS` environment variable this file will contain the preserved hosts. Subsequent runs can be performed using these hosts (while they exist) with the following rake tasks:
* Performance: 
```
be rake performance_against_already_provisioned
```

* Scale
```
be rake autoscale_provisioned
```

#### pre_suite-run.log
If the run included a pre-suite the run log is captured here; this can contain useful information about how the environment was set up.

#### pre_suite-summary.txt
If the run included a pre-suite the summary is captured here.

#### sut.log
Information about the test environment can be found here.

#### tests-run.log
The output of the test run can be found here.

#### tests-summary.txt
A summary of the test run.


