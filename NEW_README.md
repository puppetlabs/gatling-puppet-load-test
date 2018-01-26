Set up Puppet Enterprise
=========================
This will configure multiple nodes.  In the simplest case you need 2 nodes: a Puppet Master, and a combination Gatling driver/metrics and puppet agent.

* Clone the gatling-puppet-load-test repo locally: https://github.com/puppetlabs/gatling-puppet-load-test
* cd into the gatling-puppet-load-test root directory
* For apples to apples runs, you can use the checked-in hosts files: pe-perf-test.cfg or foss-perf-test.cfg (default for the performance rake task).
* For a run against a PE build set BEAKER_INSTALL_TYPE=pe and provide values for BEAKER_PE_VER and BEAKER_PE_DIR environment variables
* For a run against a FOSS build set BEAKER_INSTALL_TYPE=foss and provide values for PACKAGE_BUILD_VERSION and PUPPET_AGENT_VERSION environment variables
* If you want to do something custom (which should not normally be necessary): create a beaker config file using one of the configs in this directory as a template: https://github.com/puppetlabs/gatling-puppet-load-test/blob/master/config/beaker_hosts/
* If you are using an aws puppet-bastion account
    * Assume the ESO role
        * aws sts assume-role --role-arn arn:aws:iam::028918822489:role/\<user> --role-session-name example --serial-number arn:aws:iam::103716600232:mfa/\<user> --token-code \<mfa token code>
        * Place the returned creds in your .fog file
            * Beaker-aws will look for the aws_access_key_id, aws_secret_access_key and aws_session_token keys
* Execute:
    * export BEAKER_HOSTS=\<your hosts file>
    * bundle install
    * bundle exec rake performance_gatling (takes up to 15 minutes)

### Record a Gatling run:
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
