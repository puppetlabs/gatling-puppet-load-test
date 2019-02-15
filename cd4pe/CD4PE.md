CD4PE Test Environment
=========================

# Background
This approach to setting up a cd4pe test environment uses the alternate config `pe-perf-test-cd4pe.cfg`.
This configuration builds upon the existing `pe-perf-test.cfg` file and adds the following nodes:
* perf-test-cdpe: the node where cd4pe will be installed
* perf-test-agent-testing: an agent node for use in the testing environment
* perf-test-worker: the node where the Distelli agent will be installed
* perf-test-gitlab: the node where the Docker-based Gitlab instance will be installed

The cd4pe installation uses the [module-based installation instructions](https://puppet.com/docs/continuous-delivery/2.x/install_module.html#task-8759).

# Set up the test environment
## Provision hosts and run the pre-suite
Run the `cd4pe_provision_and_presuite` rake task to provision the nodes and run the pre-suite.
The following error is currently encountered when using the 'puppetserver_perf_control' repo with cd4pe:
```
Rolling Deployment Failed. POST https://ip-10-227-3-224.amz-dev.puppet.net:4433/classifier-api/v1/groups -> HTTP 400: {"kind":"data-not-allowed","msg":"The 'config_data' field of node groups is not allowed because the 'allow-config-data' configuration setting has not been set to 'true'."}
```

In order to get a working test environment the `cd4pe_provision_and_presuite` rake task ends the pre-suite after the initial PE installation (10_install_pe).

## Set up Gitlab
The test environment uses a Docker-based installation of Gitlab.

### Install Docker and Gitlab container
Run the `cd4pe_setup_gitlab` rake task to install Docker and set up the Gitlab container on the designated host.

### Set the root password
Once the Gitlab container is running, navigate to the host in a browser.
* Set the password for the 'root' account to 'puppetlabs'.
* Navigate to `admin/application_settings/network` and enable the 'Allow requests to the local network from hooks and services' setting.

### Import the control repo
Run the `cd4pe_setup_gitlab_control_repo` rake task to import the control repo.
You should now see the control repo in Gitlab.
* Disable the 'auto-dev-ops' pipeline

# Set up PE
## Enable Code Manager
We'll be using code manager to deploy the cd4pe module, so we'll set it up before proceeding based on [the docs](https://puppet.com/docs/pe/2019.0/code_mgr_config.html#enable-code-manager-after-installation)

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
  Port 8022
  
```

* Prepare directory for control repo key
```
cd /etc/puppetlabs/puppetserver && mkdir ssh && chown pe-puppet:pe-puppet ssh
```

* Generate the key
```
ssh-keygen -t rsa -b 2048 -C "gplt@puppet.com" -f /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa -q -N "" 

```

* Set file permissions
```
cd ssh && chown pe-puppet:pe-puppet id-control_repo.rsa id-control_repo.rsa.pub

```

* Get the public key
```
cat id-control_repo.rsa.pub
```

* Copy the key and add it to Gitlab

## Update the control repo for CD4PE

### Enable Code Manager
https://puppet.com/docs/pe/2019.0/code_mgr_config.html#enable-code-manager-after-installation

In the console, set the following parameters in the puppet_enterprise::profile::master class in the PE Master node group:
* code_manager_auto_configure - true
* r10k_remote - "ssh://git@gplt-gitlab:8022/root/control-repo.git"
* r10k_private_key - "/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa"

Run puppet on the master via the console or with the command:
```
puppet agent -t
```

### Set up authentication for Code Manager
https://puppet.com/docs/pe/2019.0/code_mgr_config.html#set-up-authentication-for-code-manager

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

# Install CD4PE
https://puppet.com/docs/continuous-delivery/2.x/install_module.html

Install CD4PE using the instructions above.

## Configure CD4PE using a task
https://puppet.com/docs/continuous-delivery/2.x/install_module.html#task-8759

Configure CD4PE using the task-based instructions above.

## Integrate CD4PE with Gitlab
https://puppet.com/docs/continuous-delivery/2.x/integrations.html#task-7720

---

# TODO: Update the PE integration instructions after the next release
https://puppet.com/docs/continuous-delivery/2.x/integrate_with_puppet_enterprise.html





