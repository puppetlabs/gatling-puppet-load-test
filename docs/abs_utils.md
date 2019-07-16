# Utility scripts for ABS

**NOTE: This functionality is not publicly available and can only be used by
personnel employed by Puppet the company.**

## Background
The `abs_helper` module was initially created when updating GPLT to use the [`awsdirect`](https://github.com/puppetlabs/always-be-scheduling#apiv2awsdirect)
endpoint to provision the `mom` and `metrics` nodes used for performance testing.
This endpoint bypasses the queuing functionality of ABS and returns the requested host immediately after provisioning rather than requiring multiple requests.
Over time `abs_helper` has been updated to make it easier to make ad-hoc requests to provision hosts, originally for CD4PE testing via rake tasks.

## Scripts
To avoid the proliferation of rake tasks the following Ruby scripts have been added to the `utils/abs` directory:

### provision_pe_xl_nodes.rb
This script was created to assist in working with the [`pe_xl`](https://github.com/reidmv/reidmv-pe_xl) module.
It provisions the nodes used by the module and generates the [Bolt](https://github.com/puppetlabs/bolt) [inventory](https://puppet.com/docs/bolt/latest/inventory_file.html) and [parameter](https://puppet.com/docs/bolt/latest/writing_tasks.html#concept-21) files populated with the provisioned hosts.

EC2 hosts using the GPLT defaults (c5.2xlarge / 80GB ) are provisioned for the following roles:

#### Core roles
* master
* puppet_db
* compiler_a
* compiler_b

#### HA roles
* master_replica
* puppet_db_replica

#### Overriding the default settings
These default settings are currently hardcoded but can be updated by editing the script.
A future update to `abs_helper` will provide a CLI with the ability to specify all settings.

```
ROLES_CORE = %w[master
                puppet_db
                compiler_a
                compiler_b].freeze

ROLES_HA = %w[master_replica
              puppet_db_replica].freeze

# NOTE: set HA to true for a HA environment
HA = false
ROLES = if HA
          ROLES_CORE + ROLES_HA
        else
          ROLES_CORE
        end

...

PE_VERSION = "2019.1.0"

...

ABS_SIZE = "c5.2xlarge"
ABS_VOLUME_SIZE = "80"
```

#### Optional arguments
The script accepts the following optional arguments:
* id - This value will be specified for the `id` tag when provisioning the EC2 instance.
This can be helpful when filtering instances in the EC2 console.
The default value is `slv`.

* output_dir - This value specifies the directory where the `nodes.yaml` and `params.json` files will be created.
The default value is `./` which should be the `gatling-puppet-load-test` directory.
However, you may want to create the files elsewhere.

Run the script from the `gatling-puppet-load-test` directory:
```
bundle exec ruby ./util/abs/provision_pe_xl_nodes.rb

or

bundle exec ruby ./util/abs/provision_pe_xl_nodes.rb my_id ~/tmp/my/output/dir
```

The `pe_xl` plan can then be run from the `gatling-puppet-load-test` directory using the generated files.
Using the example in the `pe_xl` [documentation](https://github.com/reidmv/reidmv-pe_xl/blob/master/documentation/basic_usage.md#basic-usage-instructions):
```
 bolt plan run pe_xl \
   --inventory nodes.yaml \
   --modulepath ~/modules \
   --params @params.json
```

Note: this assumes the `pe_xl` module has been installed in the `~/modules` directory as specified in the documentation.
