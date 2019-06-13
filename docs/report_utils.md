GPLT Report Utilities
=========================

#### Table of Contents

- [Background](#background)
- [Gatling reports](#gatling-reports)
  * [Scripts](#scripts)
  * [Examples](#examples)
    + [Soak test results examples](#soak-test-examples)
        * [extract_csv.rb](#extract_csvrb)
        * [compare_results.rb](#compare_resultsrb)
        * [csv2html.rb](#csv2htmlrb)
        * [build_soak_report.rb](#build_soak_reportrb)
    + [Performance test examples](#performance-test-examples)
        * [split_atop_csv.rb](#split_atop_csvrb)
        * [build_perf_report.rb](#build_perf_reportrb)
    + [Performance comparison example](#performance-comparison-example)
        * [compare_results.rb](#compare_resultsrb)
        * [compare_atop.rb](#compare_atoprb)
    + [Scale test example](#scale-test-example)
        * [build_scale_csv_summary.rb](#build_scale_csv_summaryrb)
- [Puppet Metrics Collector](#puppet-metrics-collector)
    * [untar_pmc.rb](#untar_pmcrb)

# Background
These scripts were used in the process of creating the Kearney soak test report.
They are a work-in-progress. 
Some manual steps are still required, but this gets us closer to a fully automated process.

# Gatling reports
Gatling produces a detailed HTML report from the simulation.log file. 
However, our Apples to Apples test reports include a summarized comparison of the data from two test runs.
Producing this report currently requires manually copying the data from each HTML report into the corresponding table in a Google Sheets doc.
Future possibilities include using the data in BigQuery rather than relying on CSV files (see https://github.com/puppetlabs/gatling-puppet-load-test/pull/229#discussion_r188406981).

## Scripts
These scripts perform a variety of functions from extracting Gatling result data to building full reports from parameterized templates.
In the following examples the scripts are listed in the order they are used; they are listed here in alphabetical order for reference and linked to the corresponding examples:

- [build_perf_report.rb](#build_perf_reportrb)
- [build_scale_csv_summary.rb](#build_scale_csv_summaryrb)
- [build_soak_report.rb](#build_soak_reportrb)
- [compare_atop.rb](#compare_atoprb)
- [compare_results.rb](#compare_resultsrb)
- [csv2html.rb](#csv2htmlrb)
- [extract_csv.rb](#extract_csvrb)
- [split_atop_csv.rb](#split_atop_csvrb)
- [untar_pmc.rb](#untar_pmcrb)


## Examples
Notes: 
* The following examples were created using previous runs from the Johnson and Kearney releases. 
GPLT currently organizes the results directories based on the hostname; adjust actual paths accordingly.
* All commands should be run from the `util/report_utils` directory as shown in the examples below.

### Soak test examples
In order to demonstrate the full workflow the example files referenced below are the actual test results from the Johnson and Kearney releases.
They have been re-organized and archived in our AWS S3 bucket.
If you do not have access to the example test results the resulting CSV and HTML files are available in the `examples/template_defaults` directory.

Download the `kearney_example.tar.gz` file to the `examples` directory using the AWS CLI:
```
aws s3 cp s3://slv-performance-results/releases/Kearney/SLV-451/kearney_example.tar.gz examples/kearney_example.tar.gz --profile slv_s3_service_account
```

Extract the `kearney_example.tar.gz` archive to use the provided CSV, HTML, and image files in the examples below:
```
tar xzf examples/kearney_example.tar.gz -C examples
```
Note: The CSV and HTML files created in the following steps are included in the archive so running each example is not required. 
Re-running the examples will simply regenerate the files.

#### extract_csv.rb
This script parses the JSON results file for a specified test run and creates a CSV file with the data used in our Apples to Apples test report.

Run `extract_csv.rb` by providing the path to the result folder; for example:

##### Johnson:

```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby extract_csv.rb examples/kearney_example/johnson/PerfTestLarge-1538778214573
Examining Gatling data: examples/kearney_example/johnson/PerfTestLarge-1538778214573/js/stats.json

There are 6 keys

key 0: node
key 1: filemeta pluginfacts
key 2: filemeta plugins
key 3: locales
key 4: catalog
key 5: report
Creating examples/kearney_example/johnson/PerfTestLarge-1538778214573/PerfTestLarge-1538778214573.csv

```
In this example the file `PerfTestLarge-1538778214573.csv` was created.


##### Kearney:

```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby extract_csv.rb examples/kearney_example/kearney/PerfTestLarge-1557766039747
Examining Gatling data: examples/kearney_example/kearney/PerfTestLarge-1557766039747/js/stats.json

There are 6 keys

key 0: node
key 1: filemeta pluginfacts
key 2: filemeta plugins
key 3: locales
key 4: catalog
key 5: report
Creating examples/kearney_example/kearney/PerfTestLarge-1557766039747/PerfTestLarge-1557766039747.csv

```

In this example the file `PerfTestLarge-1557766039747.csv` was created.

#### compare_results.rb
This script parses two CSV files created by extract_csv.rb (or using the same format) and creates a comparison CSV file. 
In the previous example we used the results for the most recent release `PerfTestLarge-1557765424829` which created the file `PerfTestLarge-1557765424829.csv`.
We'll use this as the 'B' in our 'A to B' comparison. 
In this example the 'A' results folder is the baseline `PerfTestLarge-1538778214573`.

##### default output file name
The output filename will be generated automatically by default.
Run `compare-results.rb` by providing the CSV files to compare:

`ruby compare_results.rb a.csv b.csv`

For example:

```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby compare_results.rb examples/kearney_example/johnson/PerfTestLarge-1538778214573/PerfTestLarge-1538778214573.csv examples/kearney_example/kearney/PerfTestLarge-1557766039747/PerfTestLarge-1557766039747.csv
Comparing PerfTestLarge-1538778214573 and PerfTestLarge-1557766039747
Creating ./PerfTestLarge-1538778214573_vs_PerfTestLarge-1557766039747.csv
```

##### specified output file name
You may specify an output filename as an optional argument.
Run `compare-results.rb` by providing the CSV files to compare and an output path:

`ruby compare_results.rb a.csv b.csv output.csv`

For example:

```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby compare_results.rb examples/kearney_example/johnson/PerfTestLarge-1538778214573/PerfTestLarge-1538778214573.csv examples/kearney_example/kearney/PerfTestLarge-1557766039747/PerfTestLarge-1557766039747.csv examples/kearney_example/kearney/kearney_baseline_comparison.csv
Comparing PerfTestLarge-1538778214573 and PerfTestLarge-1557766039747
Creating examples/kearney_example/kearney/kearney_baseline_comparison.csv
```

In this example the file `kearney_baseline_comparison.csv` was created. 

#### csv2html.rb
This script leverages the csv2html functionality in `perf_results_helper.rb` to create HTML versions of every CSV file in the specified directory.

Run `csv2html.rb` by specifying the directory to process.
Using the previous perf results directory as an example:
```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby csv2html.rb examples/kearney_example
Converting CSV files to HTML in: examples/kearney_example
  Converting: examples/kearney_example/kearney/kearney_baseline_comparison.csv
  Converting: examples/kearney_example/kearney/PerfTestLarge-1557766039747/PerfTestLarge-1557766039747.csv
  Converting: examples/kearney_example/johnson/PerfTestLarge-1538778214573/PerfTestLarge-1538778214573.csv

```

In this example the following HTML files were created:
* `examples/kearney_example/kearney/kearney_baseline_comparison.csv.html`
* `examples/kearney_example/kearney/PerfTestLarge-1557766039747/PerfTestLarge-1557766039747.csv.html`
* `examples/kearney_example/johnson/PerfTestLarge-1538778214573/PerfTestLarge-1538778214573.csv.html`

#### build_soak_report.rb
This experimental script builds an HTML soak report using a Bootstrap-based template file.
It replaces parameter strings in the template with the specified information for the baseline (A) and current (B) releases.

##### Default parameter values
The default parameter values reference the examples in the `util/report_utils/examples/soak_template_defaults` directory.
To generate a report with the default example parameter values:
```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby build_report.rb
extracting table from examples/template_defaults/PerfTestLarge-A.csv.html

extracting table from examples/template_defaults/PerfTestLarge-B.csv.html

extracting table from examples/template_defaults/PerfTestLarge-A_vs_PerfTestLarge-B.csv.html

replacing parameters...

writing report to examples/sample_soak_report.html

```
You should see that the file `sample_soak_report.html` has been created in the `examples` directory and that the default parameter values have been used.

Note: The default image paths in the example reference the files in the `examples/template_defaults` directory.
In real-world use the images should be referenced relative to the results directory.

##### User-specified parameter values
The default parameter values can be overridden by setting the corresponding environment variable with the desired value.

In this example we will generate a report using the files created in the previous examples.
We will use the output directory `examples/kearney_example/kearney_soak_report`.
The image files for the Gatling result graphs have been provided in this directory.

Note: The image paths are relative to the HTML report, not the working directory.
Since the image files are contained in the destination directory for the report, only the filename is specified.

First, set the required environment variables.
The environment setup file `examples/kearney_example/example_env_setup` has been provided which you can source:
```
test.user:~/gatling-puppet-load-test/util/report_utils> source examples/kearney_example/example_env_setup
```

Alternatively they are listed below:
```
# release a
export RELEASE_A_NAME=Johnson
export RELEASE_A_NUMBER=2019.0.1
export RELEASE_A_IMAGE=johnson.png
export RESULT_A_PATH=examples/kearney_example/johnson/PerfTestLarge-1538778214573/PerfTestLarge-1538778214573.csv.html
export RESULT_A_NAME=PerfTestLarge-1538778214573

# release b
export RELEASE_B_NAME=Kearney
export RELEASE_B_NUMBER=2019.1.0
export RELEASE_B_IMAGE=kearney.png
export RESULT_B_PATH=examples/kearney_example/kearney/PerfTestLarge-1557766039747/PerfTestLarge-1557766039747.csv.html
export RESULT_B_NAME=PerfTestLarge-1557766039747

# comparison
export COMPARISON_PATH=examples/kearney_example/kearney/kearney_baseline_comparison.csv.html

# output
export OUTPUT_PATH=examples/kearney_example/kearney_soak_report/kearney_soak_report.html

```

Next, run `build_soak_report.rb` to generate the report using the specified values:
```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby build_soak_report.rb
extracting table from examples/kearney_example/johnson/PerfTestLarge-1538778214573/PerfTestLarge-1538778214573.csv.html

extracting table from examples/kearney_example/kearney/PerfTestLarge-1557766039747/PerfTestLarge-1557766039747.csv.html

extracting table from examples/kearney_example/kearney/kearney_baseline_comparison.csv.html

replacing parameters...

writing report to examples/kearney_example/kearney_soak_report/kearney_soak_report.html
```

You should see that the file `kearney_soak_report.html` has been created in the specified directory using the specified parameter values.

### Performance test examples
These examples include additional scripts used in the creation of a basic performance results report.

#### split_atop_csv.rb
Each performance report contains an `atop_log_applestoapples_json.csv` file that includes performance statistics collected from the atop logs on the master. 
This file combines summary and detail tables into the same file which thwarts the csv2html conversion.
This script splits the `atop_log_applestoapples_json.csv` file into separate standard CSV files for the summary and detail.
The example below uses the `atop_log_applestoapples_json.csv` file extracted from a previous performance run.

Run `split_atop_csv.rb` by providing the path to the `atop_log_applestoapples_json.csv` file; for example:

```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby split_atop_csv.rb examples/atop_split_example/atop_log_applestoapples_json.csv
processing CSV file: examples/atop_split_example/atop_log_applestoapples_json.csv
creating summary: examples/atop_split_example/atop_log_applestoapples_json.summary.csv
creating detail: examples/atop_split_example/atop_log_applestoapples_json.detail.csv
converting CSV files to HTML:
  converting CSV file: examples/atop_split_example/atop_log_applestoapples_json.summary.csv
  creating HTML file: examples/atop_split_example/atop_log_applestoapples_json.summary.csv.html

  converting CSV file: examples/atop_split_example/atop_log_applestoapples_json.detail.csv
  creating HTML file: examples/atop_split_example/atop_log_applestoapples_json.detail.csv.html

```

In this example the following files were created:
* `examples/atop_split_example/atop_log_applestoapples_json.summary.csv`
* `examples/atop_split_example/atop_log_applestoapples_json.summary.csv.html`
* `examples/atop_split_example/atop_log_applestoapples_json.detail.csv`
* `examples/atop_split_example/atop_log_applestoapples_json.detail.csv.html`

#### build_perf_report.rb
This experimental script builds an HTML performance report using a Bootstrap-based template file that combines the extracted results and atop data.

##### Default parameter values
The default parameter values reference the examples in the `util/report_utils/examples/perf_template_defaults` directory.
To generate a report with the default parameter values:
```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby build_perf_report.rb
building report...

extracting table from examples/perf_template_defaults/PerfTestLarge-A.csv.html

extracting table from examples/perf_template_defaults/atop_log_applestoapples_json.summary.csv.html

extracting table from examples/perf_template_defaults/atop_log_applestoapples_json.detail.csv.html

replacing parameters...

writing report to examples/example_perf_report.html

```

You should see that the file `sample_perf_report.html` has been created in the `examples` directory and that the default parameter values have been used.

##### User-specified parameter values
The default parameter values can be overridden by setting the corresponding environment variable with the desired value:
```
TEMPLATE_PATH
RESULT_PATH
RESULT_NAME
OUTPUT_PATH
RELEASE_NUMBER
RESULT_IMAGE
ATOP_SUMMARY_PATH
ATOP_DETAIL_PATH
```

### Performance comparison example
This example uses the files in the `examples/perf_comparison_example` directory.

#### compare_results.rb
See the description [above](#compare-resultsrb).
This example will compare the `PerfTestLarge-A.csv` and `PerfTestLarge-B.csv` files which were previously extracted from performance runs using the `extract_csv.rb` script.
```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby compare_results.rb examples/perf_comparison_example/PerfTestLarge-A.csv examples/perf_comparison_example/PerfTestLarge-B.csv examples/perf_comparison_example/perf_comparison_a_vs_b.csv
Comparing PerfTestLarge-A and PerfTestLarge-B
Creating examples/perf_comparison_example/perf_comparison_a_vs_b.csv
  converting CSV file: examples/perf_comparison_example/perf_comparison_a_vs_b.csv
  creating HTML file: examples/perf_comparison_example/perf_comparison_a_vs_b.csv.html

```

In this example the following files were created:
* `examples/perf_comparison_example/perf_comparison_a_vs_b.csv`
* `examples/perf_comparison_example/perf_comparison_a_vs_b.csv.html`

#### compare_atop.rb
This script parses two `atop_log_applestoapples_json.csv` files and creates a comparison CSV file.
To run `compare_atop.rb` provide the two `atop_log_applestoapples_json.csv` files and an output path.
For example:
```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby compare_atop.rb examples/perf_comparison_example/atop_log_applestoapples_json_a.csv examples/perf_comparison_example/atop_log_applestoapples_json_b.csv examples/perf_comparison_example/atop_comparison_a_vs_b.csv
Comparing examples/perf_comparison_example/atop_log_applestoapples_json_a.summary.csv and examples/perf_comparison_example/atop_log_applestoapples_json_b.summary.csv
Creating examples/perf_comparison_example/atop_comparison_a_vs_b.summary.csv
  converting CSV file: examples/perf_comparison_example/atop_comparison_a_vs_b.summary.csv
  creating HTML file: examples/perf_comparison_example/atop_comparison_a_vs_b.summary.csv.html

```

#### build_perf_comparison.rb
This experimental script builds an HTML report using a Bootstrap-based template file that combines the output of the `compare_results.rb` and `compare_atop.rb` scripts.

##### Default parameter values
The default parameter values reference the examples in the `util/report_utils/examples/perf_comparison_template_defaults` directory.
To generate a report with the default example parameter values:
```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby build_perf_comparison.rb
building report...

extracting table from examples/perf_comparison_template_defaults/perf_comparison_a_vs_b.csv.html

extracting table from examples/perf_comparison_template_defaults/atop_comparison_a_vs_b.summary.csv.html

replacing parameters...

writing report to examples/example_perf_comparison_report.html

```

In this example the file `examples/example_perf_comparison_report.html` was created.

##### User-specified parameter values
The default parameter values can be overridden by setting the corresponding environment variable with the desired value:
```
TEMPLATE_PATH
RESULT_COMPARISON_PATH
ATOP_SUMMARY_COMPARISON_PATH
RESULT_A
RELEASE_A_NAME
RELEASE_A_NUMBER
RESULT_B
RELEASE_B_NAME
RELEASE_B_NUMBER
OUTPUT_PATH
```

### Scale test example
#### build_scale_csv_summary.rb
This script creates a summary report for multiple scale test runs using the extracted CSV results (see [`extract_csv.rb`](#extract_csv.rb)) and averages the final successful iteration for each run.
Note: in the following example the result directories have been purged of everything except the extracted CSV reports.

Run `build_scale_csv_summary.rb` by providing the parent directory containing the result directories to process.
For example:
```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby build_scale_csv_summary.rb examples/scale_csv_summary_example
building report for parent dir: examples/scale_csv_summary_example

creating summary csv: examples/scale_csv_summary_example/scale_csv_summary_example.summary.csv
processing 3 results directories...
processing results dir: PERF_SCALE_1559856817
csv_path: examples/scale_csv_summary_example/PERF_SCALE_1559856817/PERF_SCALE_1559856817.csv
processing csv: PERF_SCALE_1559856817.csv
updating summary csv: examples/scale_csv_summary_example/scale_csv_summary_example.summary.csv
results: PERF_SCALE_1559856817,1400,1400,0,31678,9843,3771,3320,3501,5493,5751,66,3556573
  converting CSV file: examples/scale_csv_summary_example/PERF_SCALE_1559856817/PERF_SCALE_1559856817.scale_extract.csv
  creating HTML file: examples/scale_csv_summary_example/PERF_SCALE_1559856817/PERF_SCALE_1559856817.scale_extract.csv.html

extracting table from examples/scale_csv_summary_example/PERF_SCALE_1559856817/PERF_SCALE_1559856817.scale_extract.csv.html

processing results dir: PERF_SCALE_1559908675
csv_path: examples/scale_csv_summary_example/PERF_SCALE_1559908675/PERF_SCALE_1559908675.csv
processing csv: PERF_SCALE_1559908675.csv
updating summary csv: examples/scale_csv_summary_example/scale_csv_summary_example.summary.csv
results: PERF_SCALE_1559908675,1800,1790,10,152759,30994,23134,22060,22826,26601,27467,72,3533411
  converting CSV file: examples/scale_csv_summary_example/PERF_SCALE_1559908675/PERF_SCALE_1559908675.scale_extract.csv
  creating HTML file: examples/scale_csv_summary_example/PERF_SCALE_1559908675/PERF_SCALE_1559908675.scale_extract.csv.html

extracting table from examples/scale_csv_summary_example/PERF_SCALE_1559908675/PERF_SCALE_1559908675.scale_extract.csv.html

processing results dir: PERF_SCALE_1559924056
csv_path: examples/scale_csv_summary_example/PERF_SCALE_1559924056/PERF_SCALE_1559924056.csv
processing csv: PERF_SCALE_1559924056.csv
updating summary csv: examples/scale_csv_summary_example/scale_csv_summary_example.summary.csv
results: PERF_SCALE_1559924056,1800,1798,2,129681,26814,19730,18487,18783,22667,23262,71,3529851
  converting CSV file: examples/scale_csv_summary_example/PERF_SCALE_1559924056/PERF_SCALE_1559924056.scale_extract.csv
  creating HTML file: examples/scale_csv_summary_example/PERF_SCALE_1559924056/PERF_SCALE_1559924056.scale_extract.csv.html

extracting table from examples/scale_csv_summary_example/PERF_SCALE_1559924056/PERF_SCALE_1559924056.scale_extract.csv.html

calculating averages for summary csv: examples/scale_csv_summary_example/scale_csv_summary_example.summary.csv
  converting CSV file: examples/scale_csv_summary_example/scale_csv_summary_example.summary.csv
  creating HTML file: examples/scale_csv_summary_example/scale_csv_summary_example.summary.csv.html

extracting table from examples/scale_csv_summary_example/scale_csv_summary_example.summary.csv.html

writing report to examples/scale_csv_summary_example/scale_csv_summary_example.html

```

In this example the file `examples/scale_csv_summary_example/scale_csv_summary_example.html` was created.

# Puppet Metrics Collector
Puppet metrics data is archived each day. 
For the 14-day soak test this means results in a lot of tar files that need to be extracted so that the data can be added to the metrics viewer database.

### untar_pmc.rb
This script extracts all of the `tar.gz` files in each of the service directories (orchestrator, puppetdb, puppetserver).
Run `untar_pmc.rb` by providing the path to the puppet-metrics-collector directory; for example:
```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby untar_pmc.rb ~/tmp/puppet-metrics-collector
Extracting all tar files in /Users/test.user/tmp/puppet-metrics-collector

Extracting files for service: orchestrator
Extracting orchestrator-2019.05.14.02.30.01.tar.gz
Extracting orchestrator-2019.05.21.02.30.01.tar.gz
...

Extracting files for service: puppetdb
Extracting puppetdb-2019.05.16.01.50.01.tar.gz
Extracting puppetdb-2019.05.19.01.50.01.tar.gz
...

Extracting files for service: puppetserver
Extracting puppetserver-2019.05.15.01.45.01.tar.gz
Extracting puppetserver-2019.05.28.01.45.01.tar.gz
...

```
