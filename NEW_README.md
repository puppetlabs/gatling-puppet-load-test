Kick off Apples to Apples performance tests
=========================
By default, the performance rake task will set up a puppet master and a Gatling driver/metrics node.
It will then kick off a gatling scenario defined for apples to apples performance tests.
At the end of the run, the gatling results and atop results will be copied back to the test runner.

* Clone the gatling-puppet-load-test repo locally: https://github.com/puppetlabs/gatling-puppet-load-test
* cd into the gatling-puppet-load-test root directory
* For apples to apples runs, you can use the checked-in hosts files: [pe-perf-test.cfg](config/pe-perf-test.cfg) or [foss-perf-test.cfg](/config/foss-perf-test.cfg). These are the defaults for the performance rake task based on the specified BEAKER_INSTALL_TYPE (pe or foss).
* In order for us to take advantage of the new AWS account with access to internal network resources, you need to use [ABS](https://github.com/puppetlabs/always-be-scheduling). The 'performance' task will automatically use ABS to provision 2 AWS instances and then execute tests against those instances.
* ABS requires a token when making requests. See the [Token operations](https://github.com/puppetlabs/always-be-scheduling#token-operations) section of the ABS README file for instructions to generate a token. 
Once generated, either set the ABS_TOKEN environment variable with your token or add it to the .fog file in your home directory using the abs_token parameter. For example:
```
:default:
  :abs_token: <your abs token>
```

* To run additional tests against an existing set of hosts, run the performance_against_already_provisioned task. This task is only intended to be run against the very latest set of provisioned hosts.
* If the hosts are preserved via Beaker's 'preserve_hosts' setting, then you will need to manually execute the 'performance_deprovision_with_abs' rake task when you are done with the hosts.
* For a run against a PE build set BEAKER_INSTALL_TYPE=pe and provide values for BEAKER_PE_VER and BEAKER_PE_DIR environment variables
* For a run against a FOSS build set BEAKER_INSTALL_TYPE=foss and provide values for PACKAGE_BUILD_VERSION and PUPPET_AGENT_VERSION environment variables
* If you want to do something custom (which should not normally be necessary): create a beaker config file using one of the configs in this directory as a template: https://github.com/puppetlabs/gatling-puppet-load-test/blob/master/config/beaker_hosts/
    *  export BEAKER_HOSTS=\<your hosts file>
* Execute:
    * bundle install
    * bundle exec rake performance_gatling (takes about 4 hours)

### Kick off Opsworks performance tests
In order to execute the tests successfully with the opsworks_performance rake task, you must set the following environment variables:
* BEAKER_TESTS to 'tests/OpsWorks.rb'
* ABS_AWS_MOM_SIZE to one of: "m5.large", "c4.xlarge", "c4.2xlarge", ""
* PUPPET_SCALE_CLASS to one of: "role::by_size::small", "role::by_size::medium", "role::by_size::large", ""

Execute:
* bundle install
* bundle exec rake opsworks_performance (takes about 1.5 hours)

### Acceptance tests
You can execute the 'acceptance' rake task which will run everything in VMPooler rather than AWS and do a much shorter gatling run. This is useful for quickly testing changes to the performance test setup. If you need to execute acceptance tests in the AWS environment, you can set the following env vars:

`ABS_OS=centos-7-x86-64-west BEAKER_HOSTS=config/beaker_hosts/pe-perf-test.cfg`

### Assertions and Baseline Comparisons

In order to use the BigQuery integration, you will need to perform the following steps:

* Choose to create a new key for the perf-metrics service account - https://console.developers.google.com/iam-admin/serviceaccounts/project?project=perf-metrics&organizationId=635869474587
* Download it and save locally.
* `export GOOGLE_APPLICATION_CREDENTIALS=` setting to the location you have saved the json key file.

If you want to push the metrics to BigQuery at the end of the test run set:

`export PUSH_TO_BIGQUERY=true`

By default this will be set to `false` when running locally and `true` when jobs run in CI.

In order to have a baseline comparison performed at the end of the test run, set:

`export BASELINE_PE_VER=`

to the version of PE you want to compare against.

Things to note:

* If any of the test specific assertions fail, the baseline comparison assertions will not be executed.
* If BASELINE_PE_VER has not been set than the baseline comparison assertions in the last test step will not be run (test step will be skipped).
* Whatever string you pass to the job to indicate the BEAKER_PE_VER needs to be used consistently. For example, if you set the version in the format `2018.1.1-rc0-11-g8fbde83` you need to use this again as the BASELINE_PE_VER or the test will error/not return expected results.
* If BASELINE_PE_VER is not found in BigQuery then the last step will error.
* Results are not overwritten, we get the latest result that matches BASELINE_PE_VER and the current test name.
* We currently only push up the data we need in order to perform the assertions.

### Set up Puppet Enterprise and Gatling but do not execute a gatling scenario
Another use for the performance task would be to record and playback a new scenario either for one-off testing,
or for a new scenario that will be checked in and used.  Additionally, you may just want to execute the setup standalone and then execute the tests later.
* Follow the above instructions, but also `export BEAKER_TESTS=` and `BEAKER_PRESERVE_HOSTS=always` prior to executing the rake task to tell beaker not to execute any tests and preserve the machines.
* Depending on your use case, you can also choose to execute the 'acceptance' task which will run in vmpooler rather than AWS. This is useful when testing/debugging but not for actual performance measurement.

### Record a Gatling run:
Assuming that you ran the performance task with no tests, you can follow the directions below to record and then play back a recording manually.
* Ensure you are still SSH'd to the Gatling driver node (metrics) using the -Y argument `ssh -Y root@<driver-host>`
* Execute `cd ~/gatling-puppet-load-test/proxy-recorder`
* Execute `sh ./launch-gatling-proxy.sh`
* Follow the steps from the script
* In the Gatling recorder GUI:
    * Change the ‘listening port’ to 7000
    * Change ‘class name’ to a unique value with no spaces such as ‘HoytApples’ - remember this, as this is the \<GatlingClassName> in subsequent steps.
    * Press start
* Back in the cmd line on the Gatling driver node, press “enter”
* Copy the command to execute on the agent node
* SSH into the agent node and:  (Ignore instructions from the script)
    * Paste in the command
    * Replace value for --server with the FQDN of the MOM
    * Replace value for --http_proxy_host with the IP address of the Gatling driver node
    * Change the value for --http_proxy_port to 7000
    * Execute the command
* Ensure that traffic was captured (rows should appear in the ‘executed events’ section of the Gatling recorder GUI)
* Press ‘Stop and Save’
* Close the GUI
* On the Gatling driver node, press enter
* Continue to follow the script.
    * When asked for the certname prefix enter any value containing the string ‘agent’. For example perf-agent-0
    * When asked for Puppet classes, enter the configuration which defaults to: role::by_size::large
        * You can use a different puppet class by specifying it as the `PUPPET_SCALE_CLASS` environment variable for the performance_gatling rake task.

### Getting a pre-recorded run started
For the following steps, GatlingClassName is the value entered into the ClassName field during the recording step.
From root of the gatling-puppet-load-test source dir on the Gatling driver (metrics):
* First time only:
    * edit /usr/share/sbt/conf/sbtopts and change “-mem” to 2048 (and uncomment)
* For each new simulation:
    * `cd ~/gatling-puppet-load-test/simulation-runner`
    * `export GEM_SOURCE=http://rubygems.delivery.puppetlabs.net`
    * `export SUT_HOST=<MOM_OR_LB_HOSTNAME>.us-west-2.compute.internal`
    * Create a json file containing your settings at config/scenarios/\<GatlingClassName>.json, example here: Gist
        * Change node_config to \<GatlingClassName>.json (this file should exist in simulation-runner/config/nodes)
    * `export PUPPET_GATLING_SIMULATION_CONFIG=../simulation-runner/config/scenarios/<GatlingClassName>.json`
    * `export PUPPET_GATLING_SIMULATION_ID=<GatlingClassName>`
    * `PUPPET_GATLING_MASTER_BASE_URL=https://$SUT_HOST:8140 sbt run`

### Analyzing results
* Gatling results, including HTML visualizations show up in the directory: gatling-puppet-load-test/simulation-runner/results/\<GatlingClassName>-\<epoch_time>/
    * scp them locally and you can view them in your browser.
* atop files containing cpu, mem, disk and network usage overall and broken down per process are available to view on the mom: atop -r /var/log/atop/atop_\<date>
    * See the atop man file for interactive commands
    
### Aborting a test run
The easiest way to immediately kill a test run is to kill the corresponding Java process on the metrics node. Find the process id with top and then use `kill <PID>`.

### Generating reports for aborted runs
If a Gatling scenario is aborted the reports may not be generated. In this case you can run Gatling in reports-only mode to generate the reports for a previous run (assuming that the hosts have been preserved). 
You'll need to specify the name of the folder on the metrics node containing the simulation.log file for the run. 
Look in `~/gatling-puppet-load-test/simulation-runner/results` for a folder that starts with 'PerfTestLarge-' followed by the run id and verify that the folder contains a valid (non-empty) simulation.log file.

If you find that the simulation.log file is not being populated during your run you may need to reduce the log buffer size from the 8kb default.
Set `gatling.data.file.bufferSize` in `simulation-runner/gatling.conf` to a smaller value like 256 (this may impact performance).

To run in reports-only mode, run as you normally would against previously provisioned hosts and set the environment variables PUPPET_GATLING_REPORTS_ONLY=true and PUPPET_GATLING_REPORTS_TARGET=<YOUR_RESULT_FOLDER>.

For example: `bundle exec rake performance_against_already_provisioned BEAKER_INSTALL_TYPE=pe BEAKER_PRE_SUITE= BEAKER_PRESERVE_HOSTS=always BEAKER_HOSTS=log/hosts_preserved.yml PUPPET_GATLING_REPORTS_ONLY=true PUPPET_GATLING_REPORTS_TARGET=PerfTestLarge-1524773045554`

After the run you should see that the report files have been generated within the result folder and copied to your local machine.
