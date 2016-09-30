## gatling-puppet-load-test Jenkinsfile syntax

So, you want to create a new perf test, and you need to build a new Ja^Henkinsfile?  You've come to the right place.

The easiest thing to do is just to create a directory for your new scenario, copy one of the existing Jenkinsfiles,
and modify it.  The [single-pass-scenario](./scenarios/single-pass-scenario/Jenkinsfile) is probably the most basic example.
The most advanced example we have at the time of this writing is probably the [couch-static-catalogs](./couch-static-catalogs/Jenkinsfile)
test.

At the end of the day, though, these files all follow a pretty simple pattern:

1. Check out the g-p-l-t repo so that we can load groovy code from it.
2. Load the library code from [pipeline.groovy](./common/scripts/jenkins/pipeline.groovy)
3. Create one or more data structures (simple groovy map objects) describing the PE/Puppet Server instance you wish to
   test
4. Call either the 'single-pipeline' or 'multipass-pipeline' methods from the pipeline library code, passing in your
   PE / Puppet Server configuration.

### Loading the g-p-l-t pipeline library

Every Jenkinsfile will start with a stanza that looks like this:

```groovy
node {
    checkout scm
    pipeline = load 'jenkins-integration/jenkins-jobs/common/scripts/jenkins/pipeline.groovy'
}
```

The `node` block just ensures that Jenkins gives us a dedicated executor node to run the step on.  The `checkout scm`
basically just says to make sure we have a local working copy of the VCS repo that relates to this job; it'll clone one
if we don't have one already, e.g. if this part of the job is running on a slave node that is different from where the
job was launched.

The `pipeline = load` block just causes the groovy code from that library file to be loaded, and the result is made
available to us as a local variable called `pipeline`.  We can now call either the `single-pipeline` or `multipass-pipeline`
methods on that object, passing in a map describing the PE/Puppet Server configuration, and the library will handle
the rest of the work of setting things up and executing the perf test.

NOTE: The `pipeline.groovy` script currently contains a bunch of raw method definitions.  I would very much like to turn
it into a proper groovy Class in the future, but haven't quite had time to figure out the mechanics of that.

### The job data structure

The most interesting / important part of these Jenkinsfiles is the data structure that describes the PE/Puppet Server
configuration and the perf test to run.  Here is an example of one of those data structures.  (Several of the fields in
this map are optional, but this example excercises all of the fields that are currently available.)

NOTE: I would really like to port this stuff over to use some simple groovy classes (think POJOs... POGOs?) in the future,
to be able to get some more compile-time validation and error checking, but haven't had time to figure out how to do that
yet.  So they are just raw maps for now.

```groovy
   [job_name: "pe-couch-no-static-250",
    gatling_simulation_config: "../simulation-runner/config/scenarios/pe-couch-medium-no-static-catalogs-250-2-hours.json",
    server_version: [
             type: "pe",
             pe_version: "2016.2.0"
    ],
    code_deploy: [
             type: "r10k",
             control_repo: "git@github.com:puppetlabs/puppetlabs-puppetserver_perf_control.git",
             basedir: "/etc/puppetlabs/code-staging/environments",
             environments: ["production"],
             hiera_config_source_file: "/etc/puppetlabs/code-staging/environments/production/root_files/hiera.yaml"
    ],
    server_java_args: "-Xms12g -Xmx12g",
    puppet_settings: [
             master: [
                     "static_catalogs": "false"
             ]
    ],
    background_scripts: [
             "./jenkins-jobs/common/scripts/background/curl-server-metrics-loop.sh"
    ],
    archive_sut_files: [
             "/var/log/puppetlabs/puppetserver/metrics.json"
    ]
   ]
```

Here's some info about each of these sections:

* `job_name`: arbitrary string that will be used in a few places in the Jenkins UI to represent this job.
* `gatling_simulation_config`: path to the [scenario config file](../simulation-runner/config/scenarios) that you want to
  use for this perf test.
* `server_version`: used to choose whether to do a PE install or an OSS puppetserver install, and to specify the version.
* `code_deploy`: specifies what puppet code we need to deploy to the server in order to be able to compile the catalogs for
  the selected gatling simulation.  Currently only supports a `type` value of `r10k`, with the following additional arguments:
** `control_repo`: the URL for the r10k control repo
** `basedir`: the directory that r10k should deploy environments to; use $codedir for setups that don't have file sync,
   and code-staging for setups that do.
** `environments`: the list of environments that r10k should deploy
** `hiera_config_source_file`: if your tests will exercise hiera, you'll need a "main" hiera config file.  This argument
   specifies the path where the framework should find that file.  The framework will copy it into the correct location
   for the configured PE/Puppet Server setup.
* `server_java_args`: if you wish to override any of the Java args (for Puppet Server only, at this time), specify the
  args here.
* `puppet_settings`: if you wish to modify any of the settings in puppet.conf, provide a nested map here.  The first level
  in the map controls the section of puppet.conf that the setting should go in, and then the next level has setting key/value
  pairs.  These changes will be applied by the framework, and then the server will be restarted prior to launching the perf
  test.
* `background_scripts`: a list of paths to scripts (in the g-p-l-t repo) that should be launched as background processes
  on the SUT node before the perf test begins.  The framework will automatically stop all of these processes after the
  perf test completes.  Example use cases would be for things like curling a metrics endpoint periodically and appending
  the results to some file, so that the metrics data throughout the run will be available after the test finishes.
* `archive_sut_files`: a list of file paths on the SUT that should be archived on the Jenkins server after the run.  These
  files will appear on the build result page in Jenkins so that you can easily find and download them.  Example use cases
  are log files, and metrics data files that were generated by the `background_scripts`.

