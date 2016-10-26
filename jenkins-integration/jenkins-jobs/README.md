# perf testing job definitions

TODO: this directory is where most of the future work for the perf
testing will be done.  It's still a little messy; we could stand to clean up and
refactor a few things to keep it more organized and re-usable.  Stay tuned.

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

* The `scenarios` directory is where you go to create new perf testing jobs.  Each subdirectory
  inside the `scenarios` directory can define a single perf testing job on the Jenkins server.
  There are two files that you can create inside these subdirectories:

  * Required: a `Jenkinsfile` defining your new job.  This file defines the behavior of your
    job once it is launched and executing.  It uses the [Jenkins Pipeline Plugin](https://jenkins.io/solutions/pipeline/),
    and specifically the [Pipeline DSL syntax](https://jenkins.io/doc/pipeline/steps/).  The
    presence of this file is what will cause the seed job to create your perf testing job on
    the Jenkins server.  For more info on the syntax of one of these `Jenkinsfile`s, see
    [README_JENKINSFILE_SYNTAX.md](./README_JENKINSFILE_SYNTAX.md).

  * Optional: a `JobDSL.groovy` file.  This can be used to configure *metadata* about your job;
    for example, overriding the number of builds to retain history for, scheduling the job to run
    automatically on a cron-type interval, adding extra build parameters, etc.  Basically anything
    about the configuration of the job *before* it begins executing.  Note that this file uses
    the [Jenkins JobDSL plugin](https://github.com/jenkinsci/job-dsl-plugin/wiki) to configure jobs;
    the JobDSL API is a completely distinct API/DSL from the Pipeline DSL used in the `Jenkinsfile`.
    For more information on the syntax of one of these files, see [README_JOBDSL_SYNTAX.md](./README_JOBDSL_SYNTAX.md).

  You can also look at the existing jobs for examples.  A couple of noteworthy
  ones:

  * `scenarios/single-pass-scenario`: this shows an example of a single-pass pipeline,
     where one specific PE perf test is executed on a single SUT and the job can
     be visualized in several very granular stages.  This would be appropriate for
     jobs where you just want to monitor the change in performance of a single branch
     or feature over time, but is not as useful for comparing multiple different
     branches or features against one another.  It is also useful for seeing how long the
     different phases of the perf job (install PE, install puppet code, file sync,
     run gatling sim, etc.) take, relative to one another.

  * `scenarios/multi-pass-scenario`: this example shows how you can define multiple
     different things to do a perf test on; e.g., different versions of PE, different
     versions of a setting, etc.  The job will loop over each of the perf tests that
     you'd specified, serially, and for each one, spin up a new SUT and run the test.
     At the end it can aggregate perf data (e.g. gatling reports) for all of the
     runs and visualize them compared to one another.

  * `scenarios/oss-puppetserver-latest-1-week/JobDSL.groovy`: this contains an example
    of how to use the JobDSL to override the maximum number of builds of a specific job
    that should be retained in the history stored on the Jenkins server.

* The `common/scripts/jenkins` directory contains groovy library code that can be re-used
  across multiple perf test jobs; typically you'll load this code via your Jenkinsfile.

* The `common/scripts/job-steps` directory contains shell scripts that are used to
  implement "steps" in a job.  These are mostly delegating work to beaker, and
  are consumed by the groovy library code in `common/scripts/jenkins`; you shouldn't
  need to mess with them unless you are adding new features / configuration parameters
  to the groovy code.

* The `common/scripts/background` directory contains scripts that can be run in
  the background on your SUT while you're running your perf test, e.g. to capture
  metrics periodically during the run and make them available for archiving on
  Jenkins afterward.

