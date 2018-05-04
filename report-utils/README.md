## Report Utilities

Gatling produces a detailed HTML report from the simulation.log file. 
However, our Apples to Apples test reports include a summarized comparison of the data from two test runs.
Producing this report currently requires manually copying the data from each HTML report into the corresponding table in a Google Sheets doc.

These utility scripts have been created to assist in that process. They are a work-in-progress. Some manual steps are still required, but this gets us closer to a fully automated process.

#### extract-csv.rb

This script parses the JSON results file for a specified test run and creates a CSV file with the data used in our Apples to Apples test report.

How to use it:

In this example the result folder for our performance run will be `gatling-puppet-load-test/PERF_1524862584`. 
`PERF_1524862584` contains the following folders:

* `ip-10-227-0-132.amz-dev.puppet.net`
* `ip-10-227-3-213.amz-dev.puppet.net`

If you know which is your metrics node, start there; otherwise, it will be the one containing a `root` folder.
In our example the metrics node is `ip-10-227-0-132.amz-dev.puppet.net`. You'll need to provide the script with the full path to the result folder, for example:

```
bill.claytor:~> cd /Users/bill.claytor/RubymineProjects/gatling-puppet-load-test/report-utils 
bill.claytor:~/RubymineProjects/gatling-puppet-load-test/report-utils> ls
README.md		compare-results.rb	extract-csv.rb
bill.claytor:~/RubymineProjects/gatling-puppet-load-test/report-utils> ruby extract-csv.rb /Users/bill.claytor/RubymineProjects/gatling-puppet-load-test/PERF_1524862584/ip-10-227-0-132.amz-dev.puppet.net/root/gatling-puppet-load-test/simulation-runner/results/PerfTestLarge-1524848074511
Creating PerfTestLarge-1524848074511.csv
bill.claytor:~/RubymineProjects/gatling-puppet-load-test/report-utils> ls
PerfTestLarge-1524848074511.csv	README.md			compare-results.rb		extract-csv.rb
bill.claytor:~/RubymineProjects/gatling-puppet-load-test/report-utils> 

```

If the script succeeds, a CSV file with the name of the performance run will be created. 
In this example the file is 'PerfTestLarge-1524848074511.csv'. 

#### compare-results.rb

This script parses two CSV files created by extract-csv.rb (or using the same format) and creates a comparison CSV file. 
In the previous example we used the result folder `gatling-puppet-load-test/PERF_1524862584` which created the CSV file 'PerfTestLarge-1524848074511.csv'.
We'll use this as the 'A' in our 'A to B' comparison. In this example the 'B' results folder is `gatling-puppet-load-test/PERF_1525125295`.

```
bill.claytor:~/RubymineProjects/gatling-puppet-load-test/report-utils> ruby extract-csv.rb /Users/bill.claytor/RubymineProjects/gatling-puppet-load-test/PERF_1525125295/ip-10-227-1-189.amz-dev.puppet.net/root/gatling-puppet-load-test/simulation-runner/results/PerfTestLarge-1525110786021
Creating PerfTestLarge-1525110786021.csv
bill.claytor:~/RubymineProjects/gatling-puppet-load-test/report-utils> ls
PerfTestLarge-1524848074511.csv	README.md			extract-csv.rb
PerfTestLarge-1525110786021.csv	compare-results.rb
bill.claytor:~/RubymineProjects/gatling-puppet-load-test/report-utils> 

```

Running extract-csv.rb against our second test results folder produced the 'PerfTestLarge-1525110786021.csv' file.

Run compare-results.rb by providing it with the CSV files to compare:

`ruby compare-results.rb A.csv B.csv`

Be sure to specify the A and B result files in the right order.

For example:

```
bill.claytor:~/RubymineProjects/gatling-puppet-load-test/report-utils> ls
PerfTestLarge-1524848074511.csv	PerfTestLarge-1525110786021.csv	README.md			compare-results.rb		extract-csv.rb
bill.claytor:~/RubymineProjects/gatling-puppet-load-test/report-utils> ruby compare-results.rb PerfTestLarge-1524848074511.csv PerfTestLarge-1525110786021.csv
Comparing PerfTestLarge-1524848074511 and PerfTestLarge-1525110786021
Creating PerfTestLarge-1524848074511_vs_PerfTestLarge-1525110786021.csv
bill.claytor:~/RubymineProjects/gatling-puppet-load-test/report-utils> ls
PerfTestLarge-1524848074511.csv					README.md
PerfTestLarge-1524848074511_vs_PerfTestLarge-1525110786021.csv	compare-results.rb
PerfTestLarge-1525110786021.csv					extract-csv.rb
bill.claytor:~/RubymineProjects/gatling-puppet-load-test/report-utils> 
```

In this example the file 'PerfTestLarge-1524848074511_vs_PerfTestLarge-1525110786021.csv' was created. 
This file is structured to match the test report template so you should be able to copy and paste all of the values at once.
I created a Google Sheets template to use as an intermediate step for easier formatting:

https://docs.google.com/spreadsheets/d/1H731HTm-l6Uk_aIxu-Z0aCw_HPK6GB0rRcBAiPiX1-w/edit?usp=sharing

Make a copy of this template and paste the data cells from the CSV file into it using 'Paste Special / Values Only'. 
Then copy the updated table and paste it into the Google Doc for your Apples to Apples test report.

Future updates will fix bugs, address pain points, and remove manual steps. 
