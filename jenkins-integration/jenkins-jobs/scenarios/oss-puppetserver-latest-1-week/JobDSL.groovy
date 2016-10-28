job.with {
    // Override the maximum number of builds to retain history for.  Because this job will run for an entire week,
    // the Gatling simulation data will eat up a very large amount of disk space, so we will only retain the
    // history for the last 10 runs instead of the default of 50.
    logRotator {
        numToKeep(10)
    }
}