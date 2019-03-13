CD4PE Test Environment
=========================

# Background
This document provides instructions for setting up a CD4PE test environment using the performance pre-suite and supplementary rake tasks.

The cd4pe installation uses the [module-based installation instructions](https://puppet.com/docs/continuous-delivery/2.x/install_module.html#task-8759).

# Set up the test environment
## Configure the environment and provision the hosts

### Set the required environment variables
The following environment variables must be set:
* BEAKER_INSTALL_TYPE
* BEAKER_PE_DIR
* BEAKER_PE_VER

You can set the values manually:

```
export BEAKER_INSTALL_TYPE=pe
export BEAKER_PE_DIR=http://enterprise.delivery.puppetlabs.net/archives/releases/2019.0.1
export BEAKER_PE_VER=2019.0.1
```

or use the provided environment setup file:
```
source config/env/env_setup_2019.0.1
```

### Provision GPLT hosts and run the pre-suite
Perform a 'performance' run to provision the 'mom' and 'metrics' hosts via ABS and run the Beaker pre-suite.
For a standard performance test environment run the `performance_setup` rake task.
For a scale test environment run the `autoscale_setup` rake task.

### Provision the CD4PE hosts
The following rake tasks are provided to create the CD4PE test environment hosts via ABS:
```
rake abs_provision_environment_cd4pe          # Provision the hosts for a cd4pe test environment via ABS
rake abs_provision_host_agent                 # Provision an agent host via ABS
rake abs_provision_host_cd4pe                 # Provision a cd4pe host via ABS
rake abs_provision_host_gitlab                # Provision a gitlab host via ABS
rake abs_provision_host_worker                # Provision a worker host via ABS

```

For a full CD4PE environment run the `abs_provision_environment_cd4pe` task.
For a custom environment, run the individual tasks to provision the desired hosts.

## Set up Gitlab
The test environment uses a standard installation of Gitlab on Centos 7:
https://about.gitlab.com/install/#centos-7

The pre-requisites specified in the instructions are already in place; only the steps listed below are required:

### Install the Gitlab package
* SSH to the Gitlab host as the root user.
* Add the GitLab package repository:

```
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash


```

* Install the Gitlab package (replace 'ip-x-x-x-x.amz-dev.puppet.net' with the value for your Gitlab host):
```
EXTERNAL_URL="http://ip-x-x-x-x.amz-dev.puppet.net" yum install -y gitlab-ee
```

### Set the root password
Once Gitlab is installed and running, navigate to the host in a browser.
* Set the password for the 'root' account to 'puppetlabs'.
* Navigate to `admin/application_settings/network` and enable the 'Allow requests to the local network from hooks and services' setting.

### Import the control repo
In the Gitlab UI:
* Navigate to New Project → Import Project → Repo by URL
* Provide a project name and description
* Provide the control repo URL: https://github.com/puppetlabs/puppetlabs-puppetserver_perf_control.git
* Click the 'Create project' button

You should now see the control repo in Gitlab.

### Disable the Auto DevOps pipeline
After importing the control repo you should see an alert banner with the following text:
```
The Auto DevOps pipeline has been enabled and will be used if no alternative CI configuration file is found.
```

* Click the 'Settings' link.
* Click the 'Expand' button for the 'Auto DevOps' panel.
* Uncheck the 'Default to Auto DevOps pipeline' option.
* Click the 'Save changes' button.

### Update the control repo for CD4PE
CD4PE is designed to use the master branch as the default with additional branches per environment.

* Create a 'master' branch from the 'production' branch.
* Set the 'master' branch as the default.
* Create additional branches per environment.
* Remove extraneous branches.
* Ensure all branches are unprotected.

# Set up PE
## Code Manager
We'll be using code manager to deploy the cd4pe module, so we'll set it up next. 
The following steps are based on the documentation found here:
https://puppet.com/docs/pe/2019.0/code_mgr_config.html#enable-code-manager-after-installation

Please refer to the documentation for additional details.

### Prepare the master
@TODO: automate
* SSH to the master
* Add a entry for the Gitlab host to `/etc/hosts`:
```
<GITLAB_HOST_IP_ADDRESS>	gplt-gitlab
```

* Add the following to `~/.ssh/config`:
```
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
Host gplt-gitlab
  User git
  IdentityFile /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa
  PreferredAuthentications publickey
  UserKnownHostsFile=/dev/null  
```

* Create the 'ssh' directory and assign ownership to 'pe-puppet':
```
cd /etc/puppetlabs/puppetserver && mkdir ssh && chown pe-puppet:pe-puppet ssh
```

* Generate the 'id-control_repo' key:
```
ssh-keygen -t rsa -b 2048 -C "gplt@puppet.com" -f /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa -q -N "" 

```

* Set the file permissions:
```
cd ssh && chown pe-puppet:pe-puppet id-control_repo.rsa id-control_repo.rsa.pub

```

* Get the public key:
```
cat id-control_repo.rsa.pub
```

### Add the key to Gitlab
* Click the user icon in the far right of the Gitlab toolbar.
* Click the 'Settings' link in the dropdown panel.
* Click the 'SSH keys' link in the left nav panel.
* Paste the SSH key created in the previous section into the 'Key' text area.
* Add a name for the key to the 'Title' field.
* Click the 'Add key' button.

### Enable Code Manager
https://puppet.com/docs/pe/2019.0/code_mgr_config.html#enable-code-manager-after-installation

In the console, set the following parameters in the puppet_enterprise::profile::master class in the PE Master node group:
* code_manager_auto_configure - true
* r10k_remote - "ssh://git@gplt-gitlab/root/control-repo.git"
* r10k_private_key - "/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa"

Run puppet on the master via the console or with the command:
```
puppet agent -t
```

### Set up authentication for Code Manager
Next we will need to set up authentication for Code Manager based on the instructions found here:
https://puppet.com/docs/pe/2019.0/code_mgr_config.html#set-up-authentication-for-code-manager

Please refer to the documentation for additional details.

#### Create the Code Manager user
* Create the Code Manager user: 'Code Manager User' / 'code_manager_user'
* Add the user to the Code Deployers role
* Perform a password reset: 'puppetlabs'

#### Request the access token
https://puppet.com/docs/pe/2019.0/code_mgr_config.html#request-an-authentication-token

```
puppet-access login --lifetime 1y
```

### Test the control repo
https://puppet.com/docs/pe/2019.0/code_mgr_config.html#test-the-control-repo

* Verify the control repo
```
[root@ip-10-227-1-53 ssh]# puppet-code deploy --dry-run
--dry-run implies --wait.
--dry-run implies --all.
Dry-run deploying all environments.
Found 1 environments.
```

* Deploy the production environment
```
puppet-code deploy production --wait
```

The master is now ready to install CD4PE using the module-based approach.

# Install CD4PE
https://puppet.com/docs/continuous-delivery/2.x/install_module.html

Install CD4PE using the instructions above. 

Note: some of the CD4PE dependencies are already included in the puppetlabs-puppetserver_perf_control repo's Puppetfile.
This will be addressed in a future update; in the meantime the following example can be used (duplicates are commented out):
```
# A Puppetfile for a control repo that can be used for Puppet Server / PE perf testing

# cd4pe
mod 'puppetlabs-cd4pe', :latest

# Requirements for cd4pe
mod 'puppetlabs-concat', '4.2.1'
mod 'puppetlabs-hocon', '1.0.1'
mod 'puppetlabs-puppet_authorization', '0.4.0'
mod 'puppetlabs-stdlib', '4.25.1'
mod 'puppetlabs-docker', '3.2.0'
mod 'puppetlabs-apt', '6.2.1'
mod 'puppetlabs-translate', '1.1.0'


mod 'stahnma/epel', '1.2.2'

# Modules that have been extracted from core Puppet
mod 'puppetlabs/augeas_core', '1.0.0'
mod 'puppetlabs/sshkeys_core', '1.0.0'
mod 'puppetlabs/yumrepo_core', '1.0.0'

# Modules required to get a tomcat server up and running
mod 'puppetlabs/tomcat', '1.5.0'
#mod 'puppetlabs/stdlib', '4.12.0'
mod 'nanliu/staging', '1.0.3'
#mod 'puppetlabs/concat', '2.1.0'
mod 'puppetlabs/java', '1.6.0'

# Modules required to get a postgres server up and running
mod 'puppetlabs/postgresql', '4.9.0'
#mod 'puppetlabs/apt', '2.2.2'

# Seeing issues with latest version of gatling
#mod 'rampup_profile_gitlab',
#  :git    => 'https://github.com/Puppet-RampUpProgram/rampup_profile_gitlab',
#  :commit => '4a5599882c0e2d716be53b0f543be2af90ec6a94'
mod 'golja/influxdb', '4.0.0'
mod 'vshn/gitlab', '1.14.0'
mod 'puppetlabs/apache', '1.11.0'

##################################################################################
## MODULES BELOW THIS LINE ARE NOT USED BY ANY ROLES/PROFILES
##################################################################################

# Enable collection of Puppet api-endpoint metrics
mod 'puppetlabs-puppet_metrics_collector', '5.1.0'

# Extra modules just to increase the total amount of code in the puppet environment
## "Additional modules to complement PE installation"
mod 'hunner/hiera', '2.0.1'
mod 'puppetlabs/puppetserver_gem', '0.2.0'
mod 'puppetlabs/inifile', '1.2.0'
#mod 'puppetlabs/hocon', '0.9.4'
mod 'puppetlabs/vcsrepo', '1.3.2'
mod 'puppet/archive', '0.5.1'

## Basic linux host management
mod 'puppetlabs/accounts', '1.0.0'
mod 'jlambert121/yum', '0.2.1'
mod 'puppetlabs/ntp', '4.2.0'
mod 'puppetlabs/firewall', '1.8.1'
mod 'saz/rsyslog', '3.5.1'

## Advanced linux host management
#mod 'garethr/docker', '5.2.0'

## Common tools in an infrastructure
mod 'camptocamp/openldap', '1.14.0'
mod 'arioch/redis', '1.2.2'
mod 'saz/memcached', '2.8.1'
mod 'puppetlabs/haproxy', '1.4.0'
mod 'jfryman/nginx', '0.3.0'
mod 'rtyler/jenkins', '1.6.1'
mod 'sensu/sensu', '2.1.0'
mod 'bfraser/grafana', '2.5.0'

mod 'elasticsearch/elasticsearch', '0.11.0'
mod 'elasticsearch/logstash', '0.6.4'
mod 'elasticsearch/logstashforwarder', '0.1.1'

mod 'puppetlabs/java_ks', '1.4.1'

## Basic Windows host management
mod 'puppetlabs/acl', '1.1.2'
mod 'puppetlabs/reboot', '1.2.1'
mod 'chocolatey/chocolatey', '1.2.3'
mod 'puppetlabs/powershell', '2.0.1'
mod 'puppetlabs/registry', '1.1.3'
mod 'puppetlabs/wsus_client', '1.0.2'
mod 'badgerious/windows_env', '2.2.2'
mod 'puppet/windows_firewall', '1.0.3'
mod 'puppet/windows_autoupdate', '1.1.0'
mod 'puppet/dotnet', '1.0.2'
mod 'puppet/windowsfeature', '1.1.0'
mod 'puppet/windows_eventlog', '1.1.1'

## Advanced Windows host management
mod 'chocolatey/chocolatey_server', '0.0.4'
# this apparently requires a PE license
#mod 'puppetlabs/sqlserver', '1.1.2'
mod 'puppet/iis', '2.0.2'
mod 'puppet/graphite_powershell', '1.0.1'

## And while we're at it, lets do this all in the cloud
mod 'puppetlabs/aws', '1.4.0'

## i18n, just putting this here created a perf issue in the past
mod 'eputnam-i18ndemo', '0.3.0'
```

The remaining steps are covered in the official documentation:

## Configure CD4PE using a task
https://puppet.com/docs/continuous-delivery/2.x/install_module.html#task-8759

## Integrate CD4PE with Gitlab
https://puppet.com/docs/continuous-delivery/2.x/integrations.html#task-7720

# Integrate CD4PE with PE
https://puppet.com/docs/continuous-delivery/2.x/integrate_with_puppet_enterprise.html

# Configure Impact Analysis
https://puppet.com/docs/continuous-delivery/2.x/configure_impact_analysis.html#concept-4400

# Configure Job Hardware
https://puppet.com/docs/continuous-delivery/2.x/configure_job_hardware.html#concept-7483

---

Note: We are currently investigating an issue with the classification of the perf agents. 
Although the agents appear to be classified correctly the agent runs do not appear to have the expected performance impact.

TODO: Include additional information on test scenario configuration.
