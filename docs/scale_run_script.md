# Using the scale run script

The [utils/scale_run.sh](../utils/scale_run.sh) script is used to automate the
execution of scale testing for the various EC2 instance types.  This script
runs 5 rounds each of cold start and warm start scenarios.  It creates a
directory for each run.

Out of the box, it will run the following.  The variable values are declared
in the begining of the script.

* 1 cold start run for the trial license (10 hosts) scenario.  Tuning is set
  to true, but is not forced, so it will not be applied to this instance due
  to insufficient ram.
    * m5.large: Starting with `TRIAL_L_COLD_TUNED_BASE_INSTANCES` instances.
* 5 cold start runs (provisioning on the first) with tune set to true on the
  following:
    * c5.xlarge: Starting with `STD_XL_COLD_TUNED_BASE_INSTANCES` instances
    * c5.2xlarge: Starting with `STD_2XL_COLD_TUNED_BASE_INSTANCES` instances
    * c5.4xlarge: Starting with `STD_4XL_COLD_TUNED_BASE_INSTANCES` instances
* 5 warm start runs (using the provisioned hosts from the cold run above) with
  tune set to true on the following:
    * c5.xlarge: Starting with `STD_XL_WARM_TUNED_BASE_INSTANCES` instances
    * c5.2xlarge: Starting with `STD_2XL_WARM_TUNED_BASE_INSTANCES` instances
    * c5.4xlarge: Starting with `STD_4XL_WARM_TUNED_BASE_INSTANCES` instances

This behaviour is executed via the following command:
```
./util/scale_run.sh 2019.1.0
```


## Environment Preparation

This script should be executed on a test runner set up as per the
[gplt setup instructions](slv_environment_setup.md) with adequate
storage space for all of the logs (100GB recommended).


## Command line flags

### No-op mode

The script provides a simple no-op mode that will echo out the ENV variable
settings as well as the scale command to be executed for each run.  This
mode is invoked with the `-n` or `--noop` flag.


### Tuning

The application of pe-tune can be toggled using the `--tune` or `--notune`
flags.  Having tuning applied is the default.


### Run ID

The script provides the `-i` or `--run-id` flag to enable the user to supply
an identifier to be used in the naming of the created run directories.  This
allows the user to run the script multiple times and label the runs in a
meaningful way for future reference.  For example, a JIRA ticket number might
be used with this flag.

```
./util/scale_run.sh -n -i SLV-999 2019.1.0
...
cmd=bundle exec rake autoscale_cold > "20190617160446-SLV-999-trial-c5.large-tune-true-cold-0.log"
```

## Customizing the settings

There are numerous variables used by the underlying `autoscale` rake tasks.
For the user's convenience, they have been grouped at the beginning of the
script.  The user should review and set these variables as desired prior
to running the script.
