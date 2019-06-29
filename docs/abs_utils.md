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
This script was created to assist in working with the pe_xl module.
It provisions the nodes used by the module and generates the Bolt inventory and parameter files populated with the provisioned hosts.

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
ABS_SIZE = "c5.2xlarge"
ABS_VOLUME_SIZE = "80"

ROLES_CORE = %w[master
                puppet_db
                compiler_a
                compiler_b].freeze

ROLES_HA = %w[master_replica
              puppet_db_replica].freeze

ROLES = ROLES_CORE + ROLES_HA
```

#### Templates
This script was written to assist in updating the `pe_xl` module to optionally set up a non-HA environment (see [SLV-365](https://tickets.puppetlabs.com/browse/SLV-365)).
It currently uses 'HA' and 'non-HA' versions of parameterized template files to create the `nodes.yaml` and `params.json` files.
These template files are located in the `utils/abs/templates` directory:
* nodes_ha.yaml
* nodes_no_ha.yaml
* params_ha.json
* params_no_ha.json

Currently, the only difference between the templates is the elimination of the HA nodes in the non-HA versions.
There is no need to edit the template files directly.
The script determines whether to use the 'HA' or 'non-HA' version of the template based on the specified roles.
While the roles are currently hardcoded, the 'HA' roles can be eliminated by changing the line:
```
ROLES = ROLES_CORE + ROLES_HA
```

to specify only the core roles:

```
ROLES = ROLES_CORE
```

If the script finds the `master_replica` role in the specified roles array it will use the 'HA' version of the template, otherwise the 'non-HA' version.
A future update will make this an optional parameter.

#### Optional arguments
The script accepts the following optional arguments:
* id - This value will be specified for the `id` tag when provisioning the EC2 instance.
This can be helpful when filtering instances in the EC2 console.
The default value is `slv`.

* output_dir - The directory where the `nodes.yaml` and `params.json` files will be created.
The default value is `./` which should be the `gatling-puppet-load-test` directory.
However, you may want to create the files elsewhere.

Run the script from the `gatling-puppet-load-test` directory:
```
ruby ./util/abs/provision_pe_xl_nodes.rb

or

ruby ./util/abs/provision_pe_xl_nodes.rb my_id ~/tmp/my/output/dir
```

The `pe_xl` plan can then be run from the `gatling-puppet-load-test` directory using the generated files.
Using the example in the `pe_xl` [documentation](https://github.com/reidmv/reidmv-pe_xl/blob/master/documentation/basic_usage.md#basic-usage-instructions):
```
 bolt plan run pe_xl \
   --inventory nodes.yaml \
   --modulepath ~/modules \
   --params @params.json
```

Note: this assumes the `pe_xl` module has been installed in the `~/modules` directory as specified the instructions.
