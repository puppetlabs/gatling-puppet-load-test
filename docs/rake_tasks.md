# Rake Tasks

This document provides further detail on the rake tasks provided as part of
this repository.  It is intended to clarify usage and workflows for tasks whose
complexity requires further explanation.

## PE_XL

The pe_xl task namespace is used for tasks that leverage the
[pe_xl module](https://github.com/reidmv/reidmv-pe_xl/).

As the namespace implies, the infrastructure managed by these task is not FOSS
compatible and is intended only to be used for PE installations.


### Deploy

`pe_xl:deploy`
: Clean; provision via ABS; run pe_xl plan.

The `pe_xl:deploy` task is the provisioning task performed by performance rake
tasks (i.e. `performance`, `soak`, `autoscale`) when the `REF_ARCH` environment
variable is set to `L`.  The `pe_xl:deploy` task performs the following tasks.
* `pe_xl:clean`
* `pe_xl:provision`
* `pe_xl:run_plan`

Running this task again will result in no action unless `pe_xl:clean` has been
run to remove the build artifacts.


#### Required Variables

The following environment variables are required by this task
* `BEAKER_PE_VER`


### Run Plan

`pe_xl:run_plan`
: Checkout pe_xl submodule; provision via ABS; run pe_xl plan.

The `pe_xl:run_plan` task updates the pe_xl submodule, runs the
`pe_xl:provision` task, and runs the `pe_xl` bolt plan for the `pe_xl`
submodule.  It captures the status of the run in a `pe_xl_plan_result` file.

Running this task again will result in no action unless
`pe_xl:clean_plan_result` has been run to remove the build artifact.


#### Required Variables
The following environment variables are required by this task
* `BEAKER_PE_VER`


### Rerun Plan

`pe_xl:rerun_plan`
: Re-run pe_xl plan.

The `pe_xl:rerun_plan` task runs the `pe_xl:clean_plan_result` task, and runs
the `pe_xl` bolt plan for the `pe_xl` submodule.  It captures the status of the
run in a `pe_xl_plan_result` file.

This is risky operation and is intended to only be performed if the the
`pe_xl:run_plan` task has failed for a transient or correctable reason.


### Provision

`pe_xl:provision`
: Provision pe_xl nodes.

The `pe_xl:provision` task runs `util/abs/provision_pe_xl_nodes.rb` to
provision the nodes needed for the **Large Reference Architecture** and create
the configuration files needed by the `pe_xl` module.


#### Required Variables

The following environment variables are required by this task
* `BEAKER_PE_VER`


### Clean

`pe_xl:clean`
: Delete pe_xl local file artifacts.

The `pe_xl:clean` task deletes the BUILD_DIR created by the `pe_xl:provision`
task.  This removes the configuration files for `pe_xl` as well as any
results from running `pe_xl:run_plan` or `pe_xl:rerun_plan` tasks.


### Clean Plan Result

`pe_xl:clean_plan_result`
: Delete pe_xl_plan_result

The `pe_xl:clean_plan_result` task deletes the `pe_xl_plan_result` file created
by the `pe_xl:run_plan` or `pe_xl:rerun_plan` tasks.  This task is used to
enable the re-running of the `pe_xl` bolt plan.
