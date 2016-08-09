// NOTE: would really like to start writing some classes/enums for some of this stuff,
// and importing them here, but it doesn't seem like support for that is really
// viable yet.  See https://issues.jenkins-ci.org/browse/JENKINS-37125 and
// https://issues.jenkins-ci.org/browse/JENKINS-31155 .

def get_server_era(pe_version) {
    // A normal groovy switch/case statement with regex matchers doesn't seem
    // to work in Jenkins: https://issues.jenkins-ci.org/browse/JENKINS-37214
    if (pe_version ==~ /^3\.[78]\..*/) {
        return [service_name: "pe-puppetserver",
                tk_auth     : false,
                puppet_bin_dir: "/opt/puppet/bin",
                r10k_version: "1.5.1",
                file_sync_available: false,
                file_sync_enabled: false,
                node_classifier: true]
    } else if (pe_version ==~ /^3\..*/) {
        return [service_name: "pe-httpd",
                tk_auth     : false,
                puppet_bin_dir: "/opt/puppet/bin",
                r10k_version: "1.5.1",
                file_sync_available: false,
                file_sync_enabled: false,
                node_classifier: false]
    } else if (pe_version ==~ /^2016\..*/) {
        return [service_name: "pe-puppetserver",
                tk_auth     : true,
                puppet_bin_dir: "/opt/puppetlabs/puppet/bin",
                r10k_version: "2.3.0",
                file_sync_available: true,
                file_sync_enabled: false,
                node_classifier: true]
    } else if (pe_version ==~ /^2015\.3\..*/) {
        return [service_name: "pe-puppetserver",
                tk_auth     : true,
                puppet_bin_dir: "/opt/puppetlabs/puppet/bin",
                r10k_version: "2.3.0",
                file_sync_available: true,
                file_sync_enabled: true,
                node_classifier: true]
    } else if (pe_version ==~ /^2015\..*/) {
        return [service_name: "pe-puppetserver",
                tk_auth     : false,
                puppet_bin_dir: "/opt/puppetlabs/puppet/bin",
                r10k_version: "2.3.0",
                file_sync_available: false,
                file_sync_enabled: false,
                node_classifier: true]
    } else {
        error "Unrecognized PE version: '${pe_version}'"
    }
}


def step000_provision_sut(SKIP_PROVISIONING, script_dir) {
    echo "SKIP PROVISIONING?: ${SKIP_PROVISIONING} (${SKIP_PROVISIONING.class})"
    if (!SKIP_PROVISIONING) {
        withEnv(["SUT_HOST=${SUT_HOST}"]) {
            sh "${script_dir}/000_provision_sut.sh"
        }
    }
}

def step010_setup_beaker(script_dir, server_version) {
    if (server_version["type"] != "pe") {
        error "Unsupported server type: ${server_version["type"]}"
    }

    withEnv(["SUT_HOST=${SUT_HOST}",
             "pe_version=${server_version["pe_version"]}",
             "pe_family=${server_version["pe_version"]}"]) {
        sh "${script_dir}/010_setup_beaker.sh"
    }
}

def step020_install_pe(SKIP_PE_INSTALL, script_dir, server_era) {
    echo "SKIP PE INSTALL?: ${SKIP_PE_INSTALL} (${SKIP_PE_INSTALL.class})"
    if (SKIP_PE_INSTALL) {
        echo "Skipping PE install because SKIP_PE_INSTALL is set."
    } else {
        withEnv(["PUPPET_SERVER_SERVICE_NAME=${server_era["service_name"]}",
                 "PUPPET_SERVER_TK_AUTH=${server_era["tk_auth"]}"]) {
            sh "${script_dir}/020_install_pe.sh"
        }
    }
}

def step030_customize_settings() {
    echo "Hi! TODO: I should be customizing PE settings on the SUT, but I'm not."
}

def step040_install_puppet_code(script_dir, code_deploy, server_era) {
    switch (code_deploy["type"]) {
        case "r10k":
            withEnv(["PUPPET_GATLING_R10K_CONTROL_REPO=${code_deploy["control_repo"]}",
                     "PUPPET_GATLING_R10K_BASEDIR=${code_deploy["basedir"]}",
                     "PUPPET_GATLING_R10K_ENVIRONMENTS=${code_deploy["environments"].join(",")}",
                     "PUPPET_BIN_DIR=${server_era["puppet_bin_dir"]}",
                     "PUPPET_R10K_VERSION=${server_era["r10k_version"]}"
                    ]) {
                sh "${script_dir}/040_install_puppet_code-r10k.sh"
            }
            break
        case "ops":
            sh "${script_dir}/040_install_puppet_code-ops_tarball.sh"
            break
        default:
            error "Unsupported code type: ${code_deploy["type"]}"
            break
    }
}

def step050_file_sync(script_dir, server_era) {
    if (server_era["file_sync_available"] == true) {
        if (server_era["file_sync_enabled"] == false) {
            echo "Server supports file sync, but it is not enabled.  Enabling."
            sh "${script_dir}/050_enable_file_sync.sh"
        }
        sh "${script_dir}/055_perform_file_sync.sh"
    } else {
        echo "Server does not support file sync, skipping."
    }
}

def step060_classify_nodes(script_dir, server_era) {
    withEnv(["PUPPET_GATLING_SIMULATION_CONFIG=${PUPPET_GATLING_SIMULATION_CONFIG}",
             "PUPPET_SERVER_SERVICE_NAME=${server_era["service_name"]}"]) {
        if (server_era["node_classifier"] == true) {
            sh "${script_dir}/060_classify_nodes-NC-API.sh"
        } else {
            echo "Node classifier not available, modifying site.pp"
            sh "${script_dir}/060_classify_nodes-site-pp.sh"
        }
    }
}

def step070_validate_classification() {
    echo "Hi! TODO: I should be validating classification on your SUT, but I'm not."
}

def step080_launch_bg_scripts() {
    echo "Hi! TODO: I should be launching background scripts on your SUT, but I'm not."
}

def step090_run_gatling_sim(job_name, script_dir) {
    withEnv(["PUPPET_GATLING_SIMULATION_CONFIG=${PUPPET_GATLING_SIMULATION_CONFIG}",
             "PUPPET_GATLING_SIMULATION_ID=${job_name}",
             "SUT_HOST=${SUT_HOST}"]) {
        sh "${script_dir}/090_run_simulation.sh"
    }
}

def step100_collect_sut_artifacts() {
    echo "Hi! TODO: I should be collecting artifacts from your SUT, but I'm not."
}

def step900_collect_driver_artifacts() {
    gatlingArchive()
}

SCRIPT_DIR = "./jenkins-integration/jenkins-jobs/common/scripts/job-steps"

def single_pipeline(job) {
    node {
        checkout scm

        SKIP_PE_INSTALL = (SKIP_PE_INSTALL == "true")
        SKIP_PROVISIONING = (SKIP_PROVISIONING == "true")

        stage '000-provision-sut'
        step000_provision_sut(SKIP_PROVISIONING, SCRIPT_DIR)

        stage '010-setup-beaker'
        step010_setup_beaker(SCRIPT_DIR, job["server_version"])

        server_era = get_server_era(job["server_version"]["pe_version"])

        stage '020-install-pe'
        step020_install_pe(SKIP_PE_INSTALL, SCRIPT_DIR, server_era)

        stage '030-customize-settings'
        step030_customize_settings()

        stage '040-install-puppet-code'
        step040_install_puppet_code(SCRIPT_DIR, job["code_deploy"], server_era)

        stage '050-file-sync'
        step050_file_sync(SCRIPT_DIR, server_era)

        stage '060-classify-nodes'
        step060_classify_nodes(SCRIPT_DIR, server_era)

        stage '070-validate-classification'
        step070_validate_classification()

        stage '080-launch-bg-scripts'
        step080_launch_bg_scripts()

        stage '090-run-gatling-sim'
        step090_run_gatling_sim(job['job_name'], SCRIPT_DIR)

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
        SKIP_PROVISIONING = (SKIP_PROVISIONING == "true")

        // NOTE: jenkins does not appear to like groovy's
        // closure syntax:
        //  `jobs.each { job ->`
        // so we use a regular for loop instead.
        for (job in jobs) {
            job_name = job['job_name']

            echo "RUNNING JOB:" + job_name

            stage job_name
            step000_provision_sut(SKIP_PROVISIONING, SCRIPT_DIR)
            step010_setup_beaker(SCRIPT_DIR, job["server_version"])
            server_era = get_server_era(job["server_version"]["pe_version"])
            step020_install_pe(SKIP_PE_INSTALL, SCRIPT_DIR, server_era)
            step030_customize_settings()
            step040_install_puppet_code(SCRIPT_DIR, job["code_deploy"], server_era)
            step050_file_sync(SCRIPT_DIR, server_era)
            step060_classify_nodes(SCRIPT_DIR, server_era)
            step070_validate_classification()
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
