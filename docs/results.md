GPLT Test Results
=========================

#### Table of Contents

- [Background](#background)
- [Performance](#performance)
  * [Host directories](#host-directories)
    + [Master](#master)  
      * [atop measurements](#atop-measurements)
      * [var logs](#var-logs)        
    + [Metric](#metric)    
      * [Gatling results](#gatling-results)
        + [HTML report](#html-report)
        + [Simulation log](#simulation-log)
        + [JSON data](#json-data)
  * [puppet-metrics-collector](#puppet-metrics-collector)
  * [Tune settings](#puppet-metrics-collector)
- [Scale](#scale)
  * [Scale test report](#scale-test-report)
  * [Beaker environment settings](#beaker-environment-settings)
  * [Iterations](#iterations)
    + [Iteration sub-directories](#iteration-sub-directories)
      * [Host directories](#host-directories-1)
        + [Master](#master-1)
        + [Metric](#metric-1)
  * [Gatling JSON data](#gatling-json-data)
  * [pe_tune](#pe_tune)
  * [puppet-metrics-collector](#puppet-metrics-collector-1)


# Background
[GPLT](https://github.com/puppetlabs/gatling-puppet-load-test) has two high-level test types: [Performance](#performance) and [Scale](#scale). 
The test results are organized into separate directories for these test types.

This document currently covers the Standard reference architecture. 
[SLV-698](https://tickets.puppetlabs.com/browse/SLV-698) has been created to update it for the Large reference architecture.

# Performance
Performance tests consist of a single iteration of a scenario such as the [Apples2Apples](https://github.com/puppetlabs/gatling-puppet-load-test#apples-to-apples-performance-tests) and [Soak](https://github.com/puppetlabs/gatling-puppet-load-test#soak-performance-tests) tests. 
The results for Performance test runs can be found in the [`results/perf`](https://github.com/puppetlabs/gatling-puppet-load-test/tree/master/results/perf) directory.

The results for each Performance test run are contained within a separate timestamped sub-directory of the `results/perf` directory.
The name of each result directory consists of the label `PERF_` to indicate a Performance run followed by a timestamp generated at the start of the run.
For example:
```
results/perf
└── PERF_1572446968
```

Performance result directories contain multiple files and sub-directories, each of which will be explained below.
For example:
  
```
results/perf/PERF_1572446968
├── 20191030T144928Z-20191030T184941Z.tar.gz
├── current_tune_settings.json
├── end_epoch
├── ip-10-227-0-214.amz-dev.puppet.net
├── ip-10-227-0-248.amz-dev.puppet.net
├── puppet-metrics-collector
├── puppetserver.average.csv
├── puppetserver.average.csv.html
├── puppetserver.csv
├── puppetserver.csv.html
└── start_epoch
```

## Host directories
The results directory contains sub-directories for each PE infrastructure host.
In the Standard reference architecture example above this would be the PE 'master'.
A sub-directory for the 'metric' node (where the Gatling simulation is run) is also included.
The name of each sub-directory corresponds to the hostname of the node.

### Master
#### atop measurements
The 'master' node directory contains the atop measurements provided by [beaker-benchmark](https://github.com/puppetlabs/beaker-benchmark) and additional CSV and HTML files generated from these files.
For example:
```
results/perf/PERF_1572446968/ip-10-227-0-214.amz-dev.puppet.net
├── atop_log_applestoapples_json.csv
├── atop_log_applestoapples_json.detail.csv
├── atop_log_applestoapples_json.detail.csv.html
├── atop_log_applestoapples_json.log
├── atop_log_applestoapples_json.log.tar.gz
├── atop_log_applestoapples_json.summary.csv
├── atop_log_applestoapples_json.summary.csv.html
├── atop_log_warmupjit_json.log
└── atop_log_warmupjit_json.log.tar.gz
```

In the above example the `atop_log_warmupjit_json.log` and `atop_log_applestoapples_json.log` files are the full atop logs produced by beaker-benchmark.
The 'warmupjit' log is created during the 'warm-up' portion of the test run; the 'applestoapples' log is created during the main portion of the test run.
Due to potentially large log file sizes beaker-benchmark compresses these files before copying to the test runner; these are the corresponding `tar.gz` files.

The `atop_log_applestoapples_json.csv` file is a CSV file containing data extracted from the corresponding log file.
It contains a summary of the measurements along with per-process measurements.
However, the formatting of this file is technically invalid due to a mismatched number of columns per row between these two sections.

As a workaround for this formatting issue the file is split into two separate CVS files: `atop_log_applestoapples_json.summary.csv` and `atop_log_applestoapples_json.detail.csv`.
This allows each section to be processed separately, including conversion to HTML documents via the [`csv2html`](https://github.com/puppetlabs/gatling-puppet-load-test/blob/7278352a6626e1f22ae8d17a7d36aa36c94b5cf4/tests/helpers/perf_results_helper.rb#L236) utility.
The HTML documents use a basic [Bootstrap](https://getbootstrap.com/) template which provides a clean layout for standalone viewing,
and allows the tables to be extracted for inclusion in larger reports.

#### var logs
TBD: [SLV-691](https://tickets.puppetlabs.com/browse/SLV-691) has been created to update this document to include the logs once the directory has been archived before copying to the results.

### Metric
#### Gatling results
The 'metric' node directory contains the Gatling results from the test run. 
These results are contained within a sub-directory of the `root/gatling-puppet-load-test/simulation-runner/results` directory.
For example:
```
results/perf/PERF_1572446968/ip-10-227-0-248.amz-dev.puppet.net
└── root
    └── gatling-puppet-load-test
        └── simulation-runner
            └── results
                └── PerfTestLarge-1572446972804
```

The results directory name consists of the scenario name (`PerfTestLarge`) and a timestamp (`1572446972804`).
This directory is generated by Gatling and includes the HTML report, simulation log file, and JSON data files.
For example:
```
PerfTestLarge-1572446972804
├── PerfTestLarge-1572446972804.csv
├── PerfTestLarge-1572446972804.csv.html
├── group_perftestlarge-5163d.html
├── index.html
├── js
├── req_perftestlarge---588ae.html
├── req_perftestlarge---8453a.html
├── req_perftestlarge---a1275.html
├── req_perftestlarge---b4f51.html
├── req_perftestlarge---db667.html
├── req_perftestlarge---de2f0.html
├── simulation.log
└── style

```

##### HTML report
The `index.html` file is the Gatling HTML report which will load automatically when this directory is viewed in a web browser.
For local viewing open the file directly.

##### Simulation log
The `simulation.log` file is the Gatling simulation log which contains a record of each transaction in the simulation.

##### JSON data
The JSON data files are contained within the `js` directory. For example:
```
PerfTestLarge-1572446972804/js
├── all_sessions.js
├── assertions.json
├── assertions.xml
├── bootstrap.min.js
├── gatling.js
├── global_stats.json
├── highcharts-more.js
├── highstock.js
├── jquery.min.js
├── menu.js
├── moment.min.js
├── stats.js
├── stats.json
├── theme.js
└── unpack.js
```

The JSON results are contained in the `global_stats.json` and `stats.json` files.

In order to make the relevant test data easily accessible and available for comparison between runs it is extracted into a CSV file via the [`gatling2csv`](https://github.com/puppetlabs/gatling-puppet-load-test/blob/7278352a6626e1f22ae8d17a7d36aa36c94b5cf4/tests/helpers/perf_results_helper.rb#L89) utility.
This is the `PerfTestLarge-1572446972804.csv` file in the example above.
As with the other CSV files in the results it is converted to an HTML document via the `csv2html` utility (`PerfTestLarge-1572446972804.csv.html`).

## puppet-metrics-collector
Metrics data for the test run is extracted from the [`puppet-metrics-collector`](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector) directory on the 'master' node via the [`collect_metrics_files`](https://github.com/puppetlabs/gatling-puppet-load-test/blob/master/util/metrics/collect_metrics_files.rb) utility.
This utility uses the timestamps in the `start_epoch` and `end_epoch` files created at the start and end of the run to copy only the data for the duration of the test run.
The data is extracted into a directory structure mirroring the original source directory and compressed into an archive named with the start and end timestamps: `20191030T144928Z-20191030T184941Z.tar.gz` in the example above.
The archive is extracted into the `puppet-metrics-collector` directory in the results which contains the relevant data.
For example:
```
results/perf/PERF_1572446968/puppet-metrics-collector
├── orchestrator
│   └── 127.0.0.1
│       ├── 20191030T145001Z.json
│       ├── ...
│       └── 20191030T185001Z.json
├── puppetdb
│   └── 127.0.0.1
│       ├── 20191030T145001Z.json
│       ├── ...
│       └── 20191030T185001Z.json
└── puppetserver
    └── 127.0.0.1
        ├── 20191030T145001Z.json
        ├── ...
        └── 20191030T185001Z.json
``` 

Some measurements are extracted from the metrics data for comparision between runs via the [`extract_puppet_metrics_collector_data`](https://github.com/puppetlabs/gatling-puppet-load-test/blob/7278352a6626e1f22ae8d17a7d36aa36c94b5cf4/tests/helpers/perf_results_helper.rb#L635) utility.
Currently the following measurements are extracted:
* static compile (mean)
* average borrow time
* num free jrubies

These measurements are extracted for each timestamp in the metrics data and stored in the `puppetserver.csv` file.
The average value for each measurement across the timestamps is calculated and stored in the `puppetserver.average.csv` file.
As with other CSV files in the results these are converted into HTML documents: `puppetserver.csv.html` and `puppetserver.average.csv.html`.

## Tune settings
The current values for the settings available for tuning via the [pe_tune](https://github.com/tkishel/pe_tune) module are captured in the `current_tune_settings.json` file.


---


# Scale
Scale tests consist of multiple iterations of a Performance scenario. 
Actually, a copy of the scenario JSON file is created for each iteration with the number of agents set based on the increment value set for the Scale run.
Each copy of the scenario is then run as a separate Performance test.

The results for Scale test runs can be found in the [`results/scale`](https://github.com/puppetlabs/gatling-puppet-load-test/tree/master/results/scale) directory.
The results for each Scale test run are contained within a separate timestamped sub-directory of the `results/scale` directory.
The name of each result directory consists of the label `SCALE_` to indicate a Scale run followed by a timestamp generated at the start of the run.
The directory also contains a `latest` link pointing to the latest Scale test results.

```
results/scale
├── PERF_SCALE_1572446292
└── latest -> /home/centos/gplt/slv-680/gatling-puppet-load-test/results/scale/PERF_SCALE_1572446292

```

Each Scale test result directory contains directories and files related to the overall Scale test run as well as each iteration of the scenario.
For example:
```
results/scale/PERF_SCALE_1572446292
├── PERF_SCALE_1572446292.csv
├── PERF_SCALE_1572446292.csv.html
├── Scale_1572446292_1_600
├── Scale_1572446292_2_700
├── Scale_1572446292_3_800
├── beaker_environment.txt
├── json
├── log
├── pe_tune_current.txt
└── puppet-metrics-collector
```

## Scale test report
The Scale test results contains a CSV file with measurements extracted from the Gatling JSON data for each iteration.
This report is useful for comparing the performance impact of additional nodes for each iteration.
It is also useful for comparing the outcome of multiple Scale test runs.

In the example above this file is `PERF_SCALE_1572446292.csv`; 
as with other CSV files in the results it has been converted to an HTML document (`PERF_SCALE_1572446292.csv.html`).

## Beaker environment settings
The `beaker_environment.txt` file contains the environment variables for the test run.

## Iterations
Each iteration of a Scale test run is actually a separate Performance test run and will create a separate result in the `results/perf` directory.
The Scale results are then constructed by selectively copying specific directories and files from the results for each iteration of the run in order to provide a cohesive overview of the entire Scale test run and to overcome the somewhat inconvenient organizational structure of the Performance results.

A separate directory is created within the Scale test results for each iteration, labeled with the following pattern:
```
Scale_{timestamp}_{iteration}_{number_of_agents}
```

This pattern makes it easy to tell how many iterations were run and how many agents were run per iteration.
For example, the directory listing above is from a sample test with three iterations:
```
results/scale/PERF_SCALE_1572446292
├── Scale_1572446292_1_600
├── Scale_1572446292_2_700
└── Scale_1572446292_3_800
```

### Iteration sub-directories
The sub-directory created for each Scale test iteration contains directories and files selectively copied from the corresponding Performance results for that iteration.
For example:
```
results/scale/PERF_SCALE_1572446292/Scale_1572446292_1_600
├── 20191030T143909Z-20191030T151209Z.tar.gz
├── current_tune_settings.json
├── end_epoch
├── master
├── metric
├── puppet-metrics-collector
├── puppetserver.average.csv
├── puppetserver.average.csv.html
├── puppetserver.csv
├── puppetserver.csv.html
└── start_epoch
```

#### Host directories
The first obvious difference between the Scale results and the Performance results is that the 'master' and 'metric' nodes are identified by their role rather than hostname.

##### Master
The 'master' directory contains the same files found in the corresponding Performance results directory.
For example:
```
results/scale/PERF_SCALE_1572446292/Scale_1572446292_1_600/master
├── atop_log_scale_1572446292_1_600_json.csv
├── atop_log_scale_1572446292_1_600_json.detail.csv
├── atop_log_scale_1572446292_1_600_json.detail.csv.html
├── atop_log_scale_1572446292_1_600_json.log
├── atop_log_scale_1572446292_1_600_json.log.tar.gz
├── atop_log_scale_1572446292_1_600_json.summary.csv
└── atop_log_scale_1572446292_1_600_json.summary.csv.html
```

These have been covered in the Performance [Performance/Host directories/Master](#master) section above.

##### Metric
The 'metric' directory contains the Gatling results found in the corresponding `root/gatling-puppet-load-test/simulation-runner/results` directory in the Performance results.
For example:

```
results/scale/PERF_SCALE_1572446292/Scale_1572446292_1_600/metric
├── PerfAutoScale-1572446523904.csv
├── PerfAutoScale-1572446523904.csv.html
├── group_perftestlarge-5163d.html
├── index.html
├── js
├── req_perftestlarge---588ae.html
├── req_perftestlarge---8453a.html
├── req_perftestlarge---a1275.html
├── req_perftestlarge---b4f51.html
├── req_perftestlarge---db667.html
├── req_perftestlarge---de2f0.html
├── simulation.log
└── style
```

These have been covered in the Performance [Performance/Host directories/Metric](#metric) section above.

## Gatling JSON data
The `stats.json` and `global_stats.json` files for each iteration are copied to the `json` directory and renamed based on the iteration naming pattern used for the iteration sub-directories.
For example:
```
results/scale/PERF_SCALE_1572446292/json
├── Scale_1572446292_1_600global_stats.json
├── Scale_1572446292_1_600stats.json
├── Scale_1572446292_2_700global_stats.json
├── Scale_1572446292_2_700stats.json
├── Scale_1572446292_3_800global_stats.json
└── Scale_1572446292_3_800stats.json
```

## Logs
The log files for the Scale test run are copied to the `log` directory.
For example:
```
results/scale/PERF_SCALE_1572446292/log
├── hosts_preserved.yml
├── pre_suite-run.log
├── pre_suite-summary.txt
├── sut.log
├── tests-run.log
└── tests-summary.txt
```

## pe_tune
The current tune settings are captured in the `pe_tune_current.txt` file.

## puppet-metrics-collector
The puppet-metrics-collector files for each iteration of the Scale run are copied to the `puppet-metrics-collector` directory,
providing metrics data for the entire Scale test run.




