# SLV Test Environment Setup

#### Table of Contents

- [Background](#background)
- [Environment setup](#environment-setup)
  * [Ruby version](#ruby-version)
  * [Gem management](#gem-management)
- [Test runner](#test-runner)
  * [Specifications](#specifications)
  * [p9_instance_setup](#p9_instance_setup)
- [Test setup and execution](#test-setup-and-execution)
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

```
➜  gplt pwd
/home/centos/gplt
➜  gplt ls
00  321a  321b  321c  321d  321k  p9
➜  gplt 
```

### Utility scripts
The [util/p9](util/p9) directory contains a set of utility scripts for cloning the gatling-puppet-load-test repo, backing up the current instance, copying reports to nginx, etc...
The scripts are designed to work from a parent directory that will contain an instance of the gatling-puppet-load-test repo with the default name.
The easiest way to get started with the scripts is to copy the 'p9' directory to the test runner and create a copy of it for each new instance.

These scripts are a work-in-progress and will eventually be converted into Bolt tasks with more extensive documentation.
Using the scripts is not required but hopefully you find that they support the common workflows and reduce the manual effort of test execution and reporting.

```
➜  gplt pwd
/home/centos/gplt
➜  gplt ls p9
backup     clone    plist  pshow    slist  sres
bkreplace  metrics  pres   replace  slog   sshow
➜  gplt cp -r p9 slv-demo
➜  gplt cd slv-demo
➜  slv-demo ls
backup     clone    plist  pshow    slist  sres
bkreplace  metrics  pres   replace  slog   sshow
➜  slv-demo 
```

#### General
##### clone
Clone the gatling-puppet-load-test repo into the current directory.
```
➜  slv-demo ls
backup     clone    plist  pshow    slist  sres
bkreplace  metrics  pres   replace  slog   sshow
➜  slv-demo ./clone
cloning gatling-puppet-load-test
Cloning into 'gatling-puppet-load-test'...
remote: Enumerating objects: 81, done.
remote: Counting objects: 100% (81/81), done.
remote: Compressing objects: 100% (60/60), done.
remote: Total 8408 (delta 32), reused 58 (delta 19), pack-reused 8327
Receiving objects: 100% (8408/8408), 5.08 MiB | 0 bytes/s, done.
Resolving deltas: 100% (4306/4306), done.
➜  slv-demo ls
backup  bkreplace  clone  gatling-puppet-load-test  metrics  plist  pres  pshow  replace  slist  slog  sres  sshow
➜  slv-demo 
```

##### backup
Create a timestamped backup of the gatling-puppet-load-test directory.
```
➜  slv-demo ls
backup  bkreplace  clone  gatling-puppet-load-test  metrics  plist  pres  pshow  replace  slist  slog  sres  sshow
➜  slv-demo ./backup
➜  slv-demo ls
backup     clone                     gplt.2019-05-01_07-10-27.tar.gz  plist  pshow    slist  sres
bkreplace  gatling-puppet-load-test  metrics                          pres   replace  slog   sshow
➜  slv-demo 
```

##### bkreplace
Create a timestamped backup of the gatling-puppet-load-test directory.
Then remove the gatling-puppet-load-test directory and re-clone the repo.
```
➜  slv-demo ls
backup  bkreplace  clone  gatling-puppet-load-test  metrics  plist  pres  pshow  replace  slist  slog  sres  sshow
➜  slv-demo ./bkreplace
backing up gatling-puppet-load-test
removing gatling-puppet-load-test
cloning gatling-puppet-load-test
Cloning into 'gatling-puppet-load-test'...
remote: Enumerating objects: 81, done.
remote: Counting objects: 100% (81/81), done.
remote: Compressing objects: 100% (60/60), done.
remote: Total 8408 (delta 32), reused 58 (delta 19), pack-reused 8327
Receiving objects: 100% (8408/8408), 5.08 MiB | 0 bytes/s, done.
Resolving deltas: 100% (4306/4306), done.
refresh complete; adding timestamp to gatling-puppet-load-test
➜  slv-demo ls
backup     clone                     gplt.2019-05-01_07-12-04.tar.gz  plist  pshow    slist  sres
bkreplace  gatling-puppet-load-test  metrics                          pres   replace  slog   sshow
➜  slv-demo 
```

##### replace
Remove the gatling-puppet-load-test directory in the current directory.
Then clone the gatling-puppet-load-test repo into the current directory.
```
➜  slv-demo ls
backup  bkreplace  clone  gatling-puppet-load-test  metrics  plist  pres  pshow  replace  slist  slog  sres  sshow
➜  slv-demo ./replace
removing gatling-puppet-load-test
cloning gatling-puppet-load-test
Cloning into 'gatling-puppet-load-test'...
remote: Enumerating objects: 81, done.
remote: Counting objects: 100% (81/81), done.
remote: Compressing objects: 100% (60/60), done.
remote: Total 8408 (delta 32), reused 58 (delta 19), pack-reused 8327
Receiving objects: 100% (8408/8408), 5.08 MiB | 0 bytes/s, done.
Resolving deltas: 100% (4306/4306), done.
refresh complete; adding timestamp to gatling-puppet-load-test
➜  slv-demo ls
backup  bkreplace  clone  gatling-puppet-load-test  metrics  plist  pres  pshow  replace  slist  slog  sres  sshow
➜  slv-demo 
```

#### Performance
##### plist
List the result folders in the ‘gatling-puppet-load-test/results/perf’ directory.
```
➜  slv-demo ls
321k  backup  bkreplace  clone  gatling-puppet-load-test  metrics  plist  pres  pshow  replace  slist  slog  sres  sshow
➜  slv-demo ./plist
total 8
drwxrwxr-x. 22 centos centos 4096 May  1 07:14 .
drwxrwxr-x.  4 centos centos   46 May  1 07:14 ..
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556563726
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556565634
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556568072
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556569897
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556571720
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556573542
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556575364
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556577196
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556579091
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556580971
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556582800
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556584646
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556637018
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556638848
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556640672
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556642539
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556644381
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556646207
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556648072
drwxrwxr-x.  4 centos centos   86 May  1 07:14 PERF_1556649975
-rw-rw-r--.  1 centos centos   66 May  1 07:14 PERF_RESULTS.md
➜  slv-demo 
```

##### pshow
List the contents of the specified result folder.
```
➜  slv-demo ./pshow PERF_1556649975
total 8
drwxrwxr-x.  4 centos centos   86 May  1 07:14 .
drwxrwxr-x. 22 centos centos 4096 May  1 07:14 ..
drwxrwxr-x.  3 centos centos   17 May  1 07:14 ip-10-227-1-27.amz-dev.puppet.net
drwxrwxr-x.  2 centos centos 4096 May  1 07:14 ip-10-227-2-91.amz-dev.puppet.net
➜  slv-demo 
```

##### pres
Copy the specified result folder to the specified nginx directory (the default is ‘slv’).
```
➜  slv-demo ./pres PERF_1556649975                           
➜  slv-demo ls /usr/share/nginx/html/gplt/perf/slv
➜  2019.0.1  PERF_1556649975  PERF_1556649975.tar.gz
➜  slv-demo 
```

#### Scale
##### slist
List the result folders in the ‘gatling-puppet-load-test/results/perf’ directory.
```
➜  slv-demo ./slist
total 20
drwxrwxr-x.  5 centos centos 4096 May  1 07:28 .
drwxrwxr-x.  4 centos centos   46 May  1 07:14 ..
lrwxrwxrwx.  1 centos centos   87 May  1 07:28 latest -> /home/centos/gplt/slv-demo/gatling-puppet-load-test/results/scale/PERF_SCALE_1556635175
drwxrwxr-x.  7 centos centos 4096 May  1 07:14 PERF_SCALE_1556561621
drwxrwxr-x. 15 centos centos 4096 May  1 07:14 PERF_SCALE_1556566242
drwxrwxr-x. 13 centos centos 4096 May  1 07:14 PERF_SCALE_1556635175
-rw-rw-r--.  1 centos centos   73 May  1 07:14 SCALE_RESULTS.md
➜  slv-demo 
```

##### slog
View the tests-run.log file for the specified scale run using `less` (type `q` to quit).
```
➜  slv-demo ./slog PERF_SCALE_1556635175

Begin tests/Scale.rb

Scale
localhost $ scp simulation-runner/config/scenarios ip-10-227-1-27.amz-dev.puppet.net:gatling-puppet-load-test/simulation-runner/config {:ignore => }
...

```

##### sshow
List the contents of the specified result folder.
```
➜  slv-demo ./sshow PERF_SCALE_1556635175
total 28
drwxrwxr-x. 13 centos centos 4096 May  1 07:14 .
drwxrwxr-x.  5 centos centos 4096 May  1 07:28 ..
-rw-rw-r--.  1 centos centos  517 May  1 07:14 beaker_environment.txt
drwxrwxr-x.  2 centos centos 4096 May  1 07:14 json
drwxrwxr-x.  2 centos centos   90 May  1 07:14 log
-rw-rw-r--.  1 centos centos  597 May  1 07:14 PERF_SCALE_1556635175.csv
-rw-rw-r--.  1 centos centos 3012 May  1 07:14 PERF_SCALE_1556635175.csv.html
-rw-rw-r--.  1 centos centos 1012 May  1 07:14 pe_tune_current.txt
drwxrwxr-x.  5 centos centos   59 May  1 07:14 puppet-metrics-collector
drwxrwxr-x.  5 centos centos   63 May  1 07:14 Scale_1556635175_01_4600
drwxrwxr-x.  5 centos centos   63 May  1 07:14 Scale_1556635175_02_4700
drwxrwxr-x.  5 centos centos   63 May  1 07:14 Scale_1556635175_03_4800
drwxrwxr-x.  5 centos centos   63 May  1 07:14 Scale_1556635175_04_4900
drwxrwxr-x.  5 centos centos   63 May  1 07:14 Scale_1556635175_05_5000
drwxrwxr-x.  5 centos centos   63 May  1 07:14 Scale_1556635175_06_5100
drwxrwxr-x.  5 centos centos   63 May  1 07:14 Scale_1556635175_07_5200
drwxrwxr-x.  5 centos centos   63 May  1 07:14 Scale_1556635175_08_5300
➜  slv-demo 
```

##### sres
Copy the specified result folder to the specified nginx directory (the default is ‘slv’).
```
➜  slv-demo ./sres PERF_SCALE_1556635175
➜  slv-demo ls /usr/share/nginx/html/gplt/scale/slv               
PERF_SCALE_1556635175  PERF_SCALE_1556635175.tar.gz
➜  slv-demo 
```

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
Several of the utility scripts described above help make this easier.

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

##### Performance
```
be rake performance_against_already_provisioned
```

##### Scale
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


