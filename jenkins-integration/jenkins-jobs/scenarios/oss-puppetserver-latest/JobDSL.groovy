// NOTE: we only want to cron this job and use a 'real' SUT hostname if the job
// is running on a production server.
if (serverConfig["environment"] == "production") {
    job.with {
        triggers {
            // This should run the job at a semi-random time between 9:00 and 10:59PM,
            //  on Mondays.
            cron('H H(21-22) * * 1')
        }
    }

    helper.overrideParameterDefault(job, "SUT_HOST", "puppetserver-perf-sut54.delivery.puppetlabs.net")
    helper.overrideParameterDefault(job, "SKIP_PROVISIONING", false)
}
