# JJB perf testing job definitions

TODO: this directory is where most of the future work for the perf
testing will be done.  It is currently what I would describe as
"a hot mess"; lots of cleanup and refactoring needed to make things
more organized and re-usable.  Stay tuned.

Currently:

The `run_gatling_scenario.yml` is an old template that was our first POC
of getting something up and running; we're not using it for anything at
the moment and it will probably be deleted soon.

The `ops-deployment/run_ops_deployment.yaml` is the first working end-to-end
POC.  It installs the ops modules and catalog zero and then runs a very
brief gatling run.  It was intended to be used as a mechanism for validating
the memory usage improvements in the NC class refresh work.  It will probably
be fleshed out further, refactored to try to define a better and more re-usable
life cycle that other jobs can share, etc., get some initial Jenkins plugins in
place for visualizing historical data from jobs, etc.  Whenever that's all
done, if there is still value in having a job related to testing the Burnside
NC class refresh improvements, we'll flesh it out.  Otherwise we'll scrap it
and use it as a template for whatever other jobs we do decide to continue with.