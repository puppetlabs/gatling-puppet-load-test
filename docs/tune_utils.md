# Utility scripts for use in tuning PE

## Background
The [`pe_tune`](https://github.com/tkishel/pe_tune) module "provides a Puppet subcommand puppet pe tune that outputs optimized settings for Puppet Enterprise services based upon available system resources.
Puppet Enterprise 2018.1.3 and newer includes the functionality of this module via the puppet infrastructure tune subcommand. "

## Scripts
The following Ruby scripts have been added to the `utils/tune` directory to assist in tuning PE:

### current_settings.rb
This script returns a JSON array of the current values for the settings adjusted by the 'pe_tune' module:
  https://github.com/tkishel/pe_tune

The list of settings can be found here:
  https://github.com/tkishel/pe_tune/blob/79d5db4ddc7bbf3b1c9aefcdfab7f1dc9b3c3f4e/lib/puppet_x/puppetlabs/tune.rb#L19

#### Usage

##### Running locally on the master
The script can be copied to the master and run there:
```
[root@ip-10-227-0-141 ~]# ruby current_settings.rb
[
  {
    "puppet_enterprise::master::puppetserver::jruby_max_active_instances": "5"
  },
  {
    "puppet_enterprise::master::puppetserver::reserved_code_cache": "640m"
  },
  {
    "puppet_enterprise::profile::console::java_args": "-Xmx768m -Xms768m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/var/log/puppetlabs/console-services/console-services_gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=16 -XX:GCLogFileSize=64m"
  },
  {
    "puppet_enterprise::profile::database::shared_buffers": "3571MB"
  },
  {
    "puppet_enterprise::profile::database::autovacuum_max_workers": "3"
  },
  {
    "puppet_enterprise::profile::database::autovacuum_work_mem": "637MB"
  },
  {
    "puppet_enterprise::profile::database::maintenance_work_mem": "1913MB"
  },
  {
    "puppet_enterprise::profile::database::max_connections": "400"
  },
  {
    "puppet_enterprise::profile::database::work_mem": "4MB"
  },
  {
    "puppet_enterprise::profile::master::java_args": "-Xms3840m -Xmx3840m -Djava.io.tmpdir=/opt/puppetlabs/server/apps/puppetserver/tmp -XX:ReservedCodeCacheSize=640m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/var/log/puppetlabs/puppetserver/puppetserver_gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=16 -XX:GCLogFileSize=64m"
  },
  {
    "puppet_enterprise::profile::orchestrator::java_args": "-Xmx768m -Xms768m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/var/log/puppetlabs/orchestration-services/orchestration-services_gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=16 -XX:GCLogFileSize=64m"
  },
  {
    "puppet_enterprise::profile::puppetdb::java_args": "-Xmx1071m -Xms1071m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/var/log/puppetlabs/puppetdb/puppetdb_gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=16 -XX:GCLogFileSize=64m"
  },
  {
    "puppet_enterprise::puppetdb::command_processing_threads": "2"
  }
]

```

##### Running via Bolt
The script can also be run via Bolt:
```
test.user:~/gatling-puppet-load-test> bolt script run util/tune/current_settings.rb --user root --nodes 10.227.0.141
Started on 10.227.0.141...
Finished on 10.227.0.141:
  STDOUT:
    [
      {
        "puppet_enterprise::master::puppetserver::jruby_max_active_instances": "5"
      },
      {
        "puppet_enterprise::master::puppetserver::reserved_code_cache": "640m"
      },
      {
        "puppet_enterprise::profile::console::java_args": "-Xmx768m -Xms768m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/var/log/puppetlabs/console-services/console-services_gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=16 -XX:GCLogFileSize=64m"
      },
      {
        "puppet_enterprise::profile::database::shared_buffers": "3571MB"
      },
      {
        "puppet_enterprise::profile::database::autovacuum_max_workers": "3"
      },
      {
        "puppet_enterprise::profile::database::autovacuum_work_mem": "637MB"
      },
      {
        "puppet_enterprise::profile::database::maintenance_work_mem": "1913MB"
      },
      {
        "puppet_enterprise::profile::database::max_connections": "400"
      },
      {
        "puppet_enterprise::profile::database::work_mem": "4MB"
      },
      {
        "puppet_enterprise::profile::master::java_args": "-Xms3840m -Xmx3840m -Djava.io.tmpdir=/opt/puppetlabs/server/apps/puppetserver/tmp -XX:ReservedCodeCacheSize=640m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/var/log/puppetlabs/puppetserver/puppetserver_gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=16 -XX:GCLogFileSize=64m"
      },
      {
        "puppet_enterprise::profile::orchestrator::java_args": "-Xmx768m -Xms768m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/var/log/puppetlabs/orchestration-services/orchestration-services_gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=16 -XX:GCLogFileSize=64m"
      },
      {
        "puppet_enterprise::profile::puppetdb::java_args": "-Xmx1071m -Xms1071m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/var/log/puppetlabs/puppetdb/puppetdb_gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=16 -XX:GCLogFileSize=64m"
      },
      {
        "puppet_enterprise::puppetdb::command_processing_threads": "2"
      }
    ]
Successful on 1 node: 10.227.0.141
Ran on 1 node in 2.89 seconds
```