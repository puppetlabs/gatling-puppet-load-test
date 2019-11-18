# Results Utility scripts

## Scripts
The following Ruby scripts have been added to the `util/results` directory to assist in evaluating results:

### validate2baseline
This script returns a pass/fail result for validating that a given results data set is in compliance with the given baseline.

#### Usage
The script is used in the context of the gem bundle for the gatling-puppet-load-test checkout.  Therefore, the bundle must be installed first.
```
$ bundle install
```

The simplest usage is the following.  The script requires a couple of options, so the following will print out the formal usage documentation.
```
$ bundle exec util/results/validate2baseline
```

To perform its operation, the script must be provided two options:
* `--baseline`: This is the PE baseline data to lookup and compare to (e.g. "2019.1.0")
* `--results_dir`: This is the path to the results data set that you wish to validate.

There is one optional option:
* `--test_type`:  This corresponds to the test type that was used to store the baseline data in Google Big Query.  This defaults to "apples to apples".

Example:
```
$ bundle exec util/results/validate2baseline --baseline=2019.1.0 --results_dir=$HOME/Downloads/results/perf/PERF_1571758219
PASS
$ echo $?
0
```
