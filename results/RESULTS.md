# Performance and Scale Results
gatling-puppet-load-test results are now copied to the `results/perf` and `results/scale` directories rather than the parent directory.

# Perf Results
Perf test results will be copied to the `results/perf` directory.

# Scale Results
Scale test results will be copied to the `results/scale` directory.
The `latest` link is created during scale test initialization and will point to the latest scale test results.
This is used by the `autoscale_copy_log` rake task to copy the test results after the test run.
