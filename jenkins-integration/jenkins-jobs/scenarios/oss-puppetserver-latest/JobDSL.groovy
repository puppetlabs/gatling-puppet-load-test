job.with {
    triggers {
        // This should run the job at a semi-random time between 9:00 and 10:59PM,
        //  on Mondays.
        scm('H H(21-22) * * 1')
    }
}

helper.overrideParameterDefault(job, "SUT_HOST", "puppetserver-perf-sut54.delivery.puppetlabs.net")
helper.overrideParameterDefault(job, "SKIP_PROVISIONING", false)