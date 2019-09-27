# Utility scripts for ABS

**NOTE: This functionality is not publicly available and can only be used by
personnel employed by Puppet the company.**

## Background
The `abs_helper` module was initially created when updating GPLT to use the [`awsdirect`](https://github.com/puppetlabs/always-be-scheduling#apiv2awsdirect)
endpoint to provision the `master` and `metrics` nodes used for performance testing.
This endpoint bypasses the queuing functionality of ABS and returns the requested host immediately after provisioning rather than requiring multiple requests.
Over time `abs_helper` has been updated to make it easier to make ad-hoc requests to provision hosts, originally for CD4PE testing via rake tasks.

## Scripts
To avoid the proliferation of rake tasks the following Ruby scripts have been added to the `utils/abs` directory:

### provision_pe_xl_nodes.rb
This script was created to assist in working with the [`pe_xl`](https://github.com/reidmv/reidmv-pe_xl) module.
It provisions the nodes used by the module and generates the [Bolt](https://github.com/puppetlabs/bolt) [inventory](https://puppet.com/docs/bolt/latest/inventory_file.html) and [parameter](https://puppet.com/docs/bolt/latest/writing_tasks.html#concept-21) files populated with the provisioned hosts.

EC2 hosts are provisioned for the following roles:

#### Core roles
* metrics
* master
* compiler_a
* compiler_b

#### Extra Large Architecture roles
* puppet_db

#### HA roles
* master_replica
* puppet_db_replica

#### Options
The script accepts the following options which override the default values:
```
    -h, --help                       Display the help text
        --noop                       Run in no-op mode
        --test                       Use test data rather than provisioning hosts
        --ha                         Deploy HA environment
    -a, --ref_arch REF_ARCH          Type of reference architecture to deploy (l, xl)
    -i, --id ID                      The value for the AWS 'id' tag
    -o, --output_dir DIR             The directory where the Bolt files should be written
    -v, --pe_version VERSION         The PE version to install
    -t, --type TYPE                  The AWS EC2 instance type to provision
    -s, --size SIZE                  The AWS EC2 volume size to specify
```

#### Default values
When run without specifying any options the script uses the following default values:

* HA (--ha): false
* REF_ARCH (-a, --ref_arch): l
* AWS_TAG_ID (-i, --id): slv
* OUTPUT_DIR (-o, --output_dir): ./
* PE_VERSION (-v, --pe_version): 2019.1.0
* AWS_INSTANCE_TYPE (-t, --type): c5.2xlarge
* AWS_VOLUME_SIZE (-s, --size): 80


#### Examples
Run the script from the `gatling-puppet-load-test` directory:

##### Default options
Running the script without specifying any options uses the default values listed above.
```
bundle exec ruby ./util/abs/provision_pe_xl_nodes.rb
```

##### Common usage scenarios

###### id
The `id` parameter specifies the value for the AWS 'id' tag.
You will almost always want to specify a value to identify a set of hosts.
Typically this will be a variation of the JIRA ticket number; for example:
```
bundle exec ruby ./util/abs/provision_pe_xl_nodes.rb -i slv-504-no-ha
```

###### ha (and id)
Deploy HA environment (false unless specified).  The pe_xl module does not
currently support deploying HA on a Large Architecture.  Therefore, the
`--ref_arch` option must be set to `xl` for an Extra-Large Architecture for
the `--ha` setting to be accepted.
```
bundle exec ruby ./util/abs/provision_pe_xl_nodes.rb --ref_arch xl --ha -i slv-504-ha
```

###### pe_version
Specify the PE version to install:
```
bundle exec ruby ./util/abs/provision_pe_xl_nodes.rb -v 2018.1.3
```

###### noop
This option enables no-op mode which provides output but does not provision hosts or create files.
```
bundle exec ruby ./util/abs/provision_pe_xl_nodes.rb --noop
```

###### test
This option enables test mode which uses the included test host arrays to generate the Bolt files and verifies the output.
```
bundle exec ruby ./util/abs/provision_pe_xl_nodes.rb --test
```

###### all options
Specify every option:
```
bundle exec ruby ./util/abs/provision_pe_xl_nodes.rb --noop \
    -a xl --ha    \
    -i example    \
    -o ~/tmp      \
    -v 2018.1.3   \
    -t c5.4xlarge \
    -s 120
*** Running in no-op mode ***

Would have provisioned pe_xl nodes with the following options:
  HA: true
  Output directory for Bolt inventory and parameter files: /Users/test.user/tmp
  PE version: 2018.1.3
  AWS EC2 id tag: example
  AWS EC2 instance type: c5.4xlarge
  AWS EC2 volume size: 120

Would have called:

  hosts = provision_hosts_for_roles(["metrics", "master", "puppet_db", "compiler_a", "compiler_b", "master_replica", "puppet_db_replica"],
                                    example,
                                    c5.2xlarge,
                                    120)

to provision the hosts, then:

  create_pe_xl_bolt_files(hosts, /Users/test.user/tmp)

to create the Bolt inventory and parameter files.
```

The `pe_xl` plan can then be run from the `gatling-puppet-load-test` directory using the generated files.
Using the example in the `pe_xl` [documentation](https://github.com/reidmv/reidmv-pe_xl/blob/master/documentation/basic_usage.md#basic-usage-instructions):
```
 bolt plan run pe_xl \
   --inventory nodes.yaml \
   --params @params.json
```
See [Large Architecture documentation](https://github.com/reidmv/reidmv-pe_xl/blob/master/documentation/large_deploy.md)
for an explanation of what is setup for a Large Ref Arch.
