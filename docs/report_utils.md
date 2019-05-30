GPLT Report Utilities
=========================

# Background
These scripts were used in the process of creating the Kearney soak test report.
They are a work-in-progress. 
Some manual steps are still required, but this gets us closer to a fully automated process.

## Gatling Reports
Gatling produces a detailed HTML report from the simulation.log file. 
However, our Apples to Apples test reports include a summarized comparison of the data from two test runs.
Producing this report currently requires manually copying the data from each HTML report into the corresponding table in a Google Sheets doc.
Future possibilities include using the data in BigQuery rather than relying on CSV files (see https://github.com/puppetlabs/gatling-puppet-load-test/pull/229#discussion_r188406981).

Notes: 
* The following examples were created using previous runs. 
GPLT currently organizes the results directories based on the hostname; adjust actual paths accordingly.
* The scripts should be run from the `util/report_utils` directory as shown in the examples below.

### examples.tar.gz
Extract the `examples.tar.gz` archive to use the provided CSV, HTML, and image files in the examples below:
```
test.user:~/gatling-puppet-load-test/util/report_utils> tar xzf examples.tar.gz
```

### extract_csv.rb
This script parses the JSON results file for a specified test run and creates a CSV file with the data used in our Apples to Apples test report.

Run `extract_csv.rb` by providing the full path to the result folder; for example:

```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby extract_csv.rb /Users/test.user/gatling-puppet-load-test/results/perf/PerfTestLarge-1557765424829
Examining Gatling data: /Users/test.user/gatling-puppet-load-test/results/perf/PerfTestLarge-1557765424829/js/stats.json

There are 6 keys

key 0: node
key 1: filemeta pluginfacts
key 2: filemeta plugins
key 3: locales
key 4: catalog
key 5: report
Creating PerfTestLarge-1557765424829.csv

```

If the script succeeds, a CSV file with the name of the performance run will be created. 
In this example the file is `PerfTestLarge-1557765424829.csv`. 

### compare-results.rb
This script parses two CSV files created by extract_csv.rb (or using the same format) and creates a comparison CSV file. 
In the previous example we used the results for the most recent release `PerfTestLarge-1557765424829` which created the file `PerfTestLarge-1557765424829.csv`.
We'll use this as the 'B' in our 'A to B' comparison. In this example the 'A' results folder is the baseline `PerfTestLarge-1538778214573`.

Run `compare-results.rb` by providing the CSV files to compare and an output path:

`ruby compare_results.rb a.csv b.csv output.csv`

For example:

```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby compare_results.rb /Users/test.user/gatling-puppet-load-test/results/perf/PerfTestLarge-1538778214573/PerfTestLarge-1538778214573.csv /Users/test.user/gatling-puppet-load-test/results/perf/PerfTestLarge-1557765424829/PerfTestLarge-1557765424829.csv /Users/test.user/gatling-puppet-load-test/results/perf/kearney_baseline_comparison.csv
Comparing PerfTestLarge-1538778214573 and PerfTestLarge-1557765424829
Creating /Users/test.user/gatling-puppet-load-test/results/perf/kearney_baseline_comparison.csv

```

In this example the file `kearney_baseline_comparison.csv` was created. 

### csv2html.rb
This script leverages the csv2html functionality in `perf_results_helper.rb` to create HTML versions of every CSV file in the specified directory.

Using the previous perf results directory as an example:
```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby csv2html.rb /Users/test.user/gatling-puppet-load-test/results/perf
Converting CSV files to HTML in: /Users/test.user/gatling-puppet-load-test/results/perf
  Converting: /Users/test.user/gatling-puppet-load-test/results/perf/kearney_baseline_comparison.csv
  Converting: /Users/test.user/gatling-puppet-load-test/results/perf/PerfTestLarge-1557765424829/PerfTestLarge-1557765424829.csv
  Converting: /Users/test.user/gatling-puppet-load-test/results/perf/PerfTestLarge-1538778214573/PerfTestLarge-1538778214573.csv

```

### build_report.rb
This experimental script builds an HTML soak report using a Bootstrap-based template file.
It replaces parameter strings in the template with the specified information for the baseline (A) and current (B) releases.

The default parameter values reference the examples in the `util/report_utils/examples/template` directory:
```
TEMPLATE_PATH = "./soak_results_template.html"

RESULT_A_PATH = "examples/template/PerfTestLarge-A.csv.html"
RESULT_A_NAME = "PerfTestLarge-12345678"

RESULT_B_PATH = "examples/template/PerfTestLarge-B.csv.html"
RESULT_B_NAME = "PerfTestLarge-23456789"

COMPARISON_PATH = "examples/template/PerfTestLarge-A_vs_PerfTestLarge-B.csv.html"
OUTPUT_PATH = "./example_soak_report.html"

RELEASE_A_NAME = "RELEASE A"
RELEASE_A_NUMBER = "1.2.3"
RELEASE_A_IMAGE = "examples/template/release_a.png"

RELEASE_B_NAME = "RELEASE B"
RELEASE_B_NUMBER = "2.3.4"
RELEASE_B_IMAGE = "examples/template/release_b.png"
```

To generate a report with the default example parameter values:
```
test.user:~/gatling-puppet-load-test/util/report_utils> ruby build_report.rb
extracting table from examples/template/PerfTestLarge-A.csv.html

extracting table from examples/template/PerfTestLarge-B.csv.html

extracting table from examples/template/PerfTestLarge-A_vs_PerfTestLarge-B.csv.html

replacing parameters...

writing report to ./example_soak_report.html

```
You should see that the file `example_soak_report.html` has been created in the current directory and that the default parameter values have been used.


These values can be overridden by setting the corresponding environment variable with the desired value.
For example, to change the release names and corresponding version numbers:
```
test.user:~/gatling-puppet-load-test/util/report_utils> export RELEASE_A_NAME=ALBERT
test.user:~/gatling-puppet-load-test/util/report_utils> export RELEASE_A_NUMBER=2018.0.1
test.user:~/gatling-puppet-load-test/util/report_utils> export RELEASE_B_NAME=BARTON
test.user:~/gatling-puppet-load-test/util/report_utils> export RELEASE_B_NUMBER=2019.0.1
test.user:~/gatling-puppet-load-test/util/report_utils> export OUTPUT_PATH=./barton_soak_report.html
test.user:~/gatling-puppet-load-test/util/report_utils> ruby build_report.rb
extracting table from examples/template/PerfTestLarge-A.csv.html

extracting table from examples/template/PerfTestLarge-B.csv.html

extracting table from examples/template/PerfTestLarge-A_vs_PerfTestLarge-B.csv.html

replacing parameters...

writing report to ./barton_soak_report.html

```

You should see that the file `barton_soak_report.html` has been created in the current directory and that the specified parameter values have been used.

Note: The default image paths in the example reference the files in the `examples/template` directory.
In real-world use the images should be referenced relative to the results directory (see the report `util/report_utils/examples/kearney/kearney_soak_results.html` for an example).

## Puppet Metrics Collector
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
