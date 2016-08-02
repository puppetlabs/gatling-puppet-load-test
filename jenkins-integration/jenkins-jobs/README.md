# JJB perf testing job definitions

TODO: this directory is where most of the future work for the perf
testing will be done.  It is currently what I would describe as
"a hot mess"; lots of cleanup and refactoring needed to make things
more organized and re-usable.  Stay tuned.

Currently:

* The `job_bootstrap.groovy` file is used to create a "seed" job via the Jenkins
  `JobDSL` plugin.  This job will simply look for files named `Jenkinsfile` in subdirectories
  of the `scenarios` directory, and will create one perf test job for each `Jenkinsfile` that
  it finds.  (For implementation details on how the seed job itself gets created, see the
  [puppetlabs-puppetserver_perf_driver module](https://github.com/puppetlabs/puppetlabs-puppetserver_perf_driver).
  Specifically, at the time of this writing, there is an [exec resource](https://github.com/puppetlabs/puppetlabs-puppetserver_perf_driver/blob/fd59a475331717caecbe693a04c38f8dea11dedd/manifests/profile/puppetserver/perf/driver/jjb.pp#L53-L57)
  that creates the JobDSL seed job using JJB, via [this JJB yaml file](https://github.com/puppetlabs/puppetlabs-puppetserver_perf_driver/blob/fd59a475331717caecbe693a04c38f8dea11dedd/files/jenkins/jobs/poll-for-gplt-jobs.yaml).  This is gross and
  eventually it'd be nice to figure out another way to bootstrap this seed job so we can get
  rid of JJB and all of its dependencies, since we are no longer using them for anything else.)

* The `scenarios` directory is where you go to create new perf testing jobs.  Create a subdirectory
  therein, and add a `Jenkinsfile` defining your new job.  There are two "template" jobs in there
  for now, which can be used as models to build other jobs:

** `scenarios/single-pass-scenario`: this shows an example of a single-pass pipeline,
   where one specific PE perf test is executed on a single SUT and the job can
   be visualized in several very granular stages.  This would be appropriate for
   jobs where you just want to monitor the change in performance of a single branch
   or feature over time, but is not as useful for comparing multiple different
   branches or features against one another.  It is also useful for seeing how long the
   different phases of the perf job (install PE, install puppet code, file sync,
   run gatling sim, etc.) take, relative to one another.

** `scenarios/multi-pass-scenario`: this example shows how you can define multiple
   different things to do a perf test on; e.g., different versions of PE, different
   versions of a setting, etc.  The job will loop over each of the perf tests that
   you'd specified, serially, and for each one, spin up a new SUT and run the test.
   At the end it can aggregate perf data (e.g. gatling reports) for all of the
   runs and visualize them compared to one another.

* The `common/scripts/jenkins` directory contains groovy library code that can be re-used
  across multiple perf test jobs; typically you'll load this code via your Jenkinsfile.

* The `common/scripts/job-steps` directory contains shell scripts that are used to
  implement "steps" in a job.  These are mostly delegating work to beaker, and
  are consumed by the groovy library code in `common/scripts/jenkins`; you shouldn't
  need to mess with them unless you are adding new features / configuration parameters
  to the groovy code.
