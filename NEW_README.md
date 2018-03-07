Kick off Apples to Apples performance tests
=========================
By default, the performance rake task will set up a puppet master and a Gatling driver/metrics node.
It will then kick off a gatling scenario defined for apples to apples performance tests.
At the end of the run, the gatling results and atop results will be copied back to the test runner.

* Clone the gatling-puppet-load-test repo locally: https://github.com/puppetlabs/gatling-puppet-load-test
* cd into the gatling-puppet-load-test root directory
* For apples to apples runs, you can use the checked-in hosts files: pe-perf-test.cfg or foss-perf-test.cfg (default for the performance rake task).
* In order for us to take advantage of the new AWS account with access to internal network resources, you need to use ABS. The 'performance' task will automatically use ABS to provision 2 AWS instances and then execute tests against those instances.
* If the hosts are preserved via Beaker's 'preserve_hosts' setting, then you will need to manually execute the 'performance_deprovision_with_abs' rake task when you are done with the hosts.
* For a run against a PE build set BEAKER_INSTALL_TYPE=pe and provide values for BEAKER_PE_VER and BEAKER_PE_DIR environment variables
* For a run against a FOSS build set BEAKER_INSTALL_TYPE=foss and provide values for PACKAGE_BUILD_VERSION and PUPPET_AGENT_VERSION environment variables
* If you want to do something custom (which should not normally be necessary): create a beaker config file using one of the configs in this directory as a template: https://github.com/puppetlabs/gatling-puppet-load-test/blob/master/config/beaker_hosts/
    *  export BEAKER_HOSTS=\<your hosts file>
* Execute:
    * bundle install
    * bundle exec rake performance_gatling (takes about 2 hours)

### Set up Puppet Enterprise and Gatling but do not execute a gatling scenario
Another use for the performance task would be to record and playback a new scenario either for one-off testing,
or for a new scenario that will be checked in and used.  Additionally, you may just want to execute the setup standalone and then execute the tests later.
* Follow the above instructions, but also `export BEAKER_TESTS=` and `BEAKER_PRESERVE_HOSTS=true` prior to executing the rake task to tell beaker not to execute any tests and preserve the machines.

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
