def step000_provision_sut(SKIP_PROVISIONING, script_dir) {
    echo "SKIP PROVISIONING?: ${SKIP_PROVISIONING} (${SKIP_PROVISIONING.class})"
    if (!SKIP_PROVISIONING) {
        withEnv(["SUT_HOST=${SUT_HOST}"]) {
            sh "${script_dir}/000_provision_sut.sh"
        }
    }
}

def step010_setup_beaker(script_dir) {
    withEnv(["SUT_HOST=${SUT_HOST}"]) {
        sh "${script_dir}/010_setup_beaker.sh"
    }
}

def step020_install_pe(SKIP_PE_INSTALL, script_dir) {
    echo "SKIP PE INSTALL?: ${SKIP_PE_INSTALL} (${SKIP_PE_INSTALL.class})"
    if (SKIP_PE_INSTALL) {
        echo "Skipping PE install because SKIP_PE_INSTALL is set."
    } else {
        sh "${script_dir}/020_install_pe.sh"
    }
}

def step030_customize_settings() {
    echo "Hi! TODO: I should be customizing PE settings on the SUT, but I'm not."
}

def step040_install_puppet_code(script_dir) {
    sh "${script_dir}/040_install_puppet_code.sh"
}

def step050_file_sync(script_dir) {
    sh "${script_dir}/050_file_sync.sh"
}

def step060_classify_nodes(script_dir) {
    withEnv(["PUPPET_GATLING_SIMULATION_CONFIG=${PUPPET_GATLING_SIMULATION_CONFIG}"]) {
        sh "${script_dir}/060_classify_nodes.sh"
    }
}

def step070_classify_nodes() {
    echo "Hi! TODO: I should be validating classification on your SUT, but I'm not."
}

def step080_launch_bg_scripts() {
    echo "Hi! TODO: I should be launching background scripts on your SUT, but I'm not."
}

def step090_run_gatling_sim(job_name, script_dir) {
    withEnv(["PUPPET_GATLING_SIMULATION_CONFIG=${PUPPET_GATLING_SIMULATION_CONFIG}",
             "PUPPET_GATLING_SIMULATION_ID=${job_name}"]) {
        sh "${script_dir}/090_run_simulation.sh"
    }
}

def step100_collect_sut_artifacts() {
    echo "Hi! TODO: I should be collecting artifacts from your SUT, but I'm not."
}

def step900_collect_driver_artifacts() {
    gatlingArchive()
}

SCRIPT_DIR = "./jenkins-integration/jenkins-jobs/common/scripts/job_steps"

def single_pipeline(job_name) {
    node {
        checkout scm

        SKIP_PE_INSTALL = (SKIP_PE_INSTALL == "true")
        SKIP_PROVISIONING = (SKIP_PROVISIONING == "true")

        stage '000-provision-sut'
        step000_provision_sut(SKIP_PROVISIONING, SCRIPT_DIR)

        stage '010-setup-beaker'
        step010_setup_beaker(SCRIPT_DIR)

        stage '020-install-pe'
        step020_install_pe(SKIP_PE_INSTALL, SCRIPT_DIR)

        stage '030-customize-settings'
        step030_customize_settings()

        stage '040-install-puppet-code'
        step040_install_puppet_code(SCRIPT_DIR)

        stage '050-file-sync'
        step050_file_sync(SCRIPT_DIR)

        stage '060-classify-nodes'
        step060_classify_nodes(SCRIPT_DIR)

        stage '070-validate-classification'
        step070_classify_nodes()

        stage '080-launch-bg-scripts'
        step080_launch_bg_scripts()

        stage '090-run-gatling-sim'
        step090_run_gatling_sim(job_name, SCRIPT_DIR)

        stage '100-collect-sut-artifacts'
        step100_collect_sut_artifacts()

        stage '900-collect-driver-artifacts'
        step900_collect_driver_artifacts()
    }
}

def multipass_pipeline(jobs) {
    node {
        checkout scm

        SKIP_PE_INSTALL = (SKIP_PE_INSTALL == "true")

        // NOTE: jenkins does not appear to like groovy's
        // closure syntax:
        //  `jobs.each { job ->`
        // so we use a regular for loop instead.
        for (job in jobs) {
            job_name = job['job_name']

            echo "RUNNING JOB:" + job_name

            stage job_name
            step000_provision_sut()
            step010_setup_beaker(SCRIPT_DIR)
            step020_install_pe(SKIP_PE_INSTALL, SCRIPT_DIR)
            step030_customize_settings()
            step040_install_puppet_code(SCRIPT_DIR)
            step050_file_sync(SCRIPT_DIR)
            step060_classify_nodes(SCRIPT_DIR)
            step070_classify_nodes()
            step080_launch_bg_scripts()
            step090_run_gatling_sim(job_name, SCRIPT_DIR)
            step100_collect_sut_artifacts()
        }

        // it's critical that the gatling archiving happens outside
        // of the loop.  If it happens inside of the loop, the first
        // run will be archived and the second one will hit a minor
        // error that prevents the summary graph from showing both
        // sets of results.
        step900_collect_driver_artifacts()
    }
}

return this;
