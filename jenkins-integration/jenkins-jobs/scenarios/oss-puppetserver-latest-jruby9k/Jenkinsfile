node {
    checkout scm
    pipeline = load 'jenkins-integration/jenkins-jobs/common/scripts/jenkins/pipeline.groovy'
}

pipeline.single_pipeline([
        job_name: 'oss-latest-jruby9k',
        gatling_simulation_config: '../simulation-runner/config/scenarios/foss5x-medium-1200-2-hours.json',
        server_version: [
                type: "oss",
                version: "latest"
        ],
        agent_version: [
                version: "latest"
        ],
        code_deploy: [
                type: "r10k",
                control_repo: "git@github.com:puppetlabs/puppetlabs-puppetserver_perf_control.git",
                basedir: "/etc/puppetlabs/code/environments",
                environments: ["production"],
                hiera_config_source_file: "/etc/puppetlabs/code/environments/production/root_files/hiera.yaml"
        ],
        background_scripts: [
                "./jenkins-jobs/common/scripts/background/curl-server-metrics-loop.sh"
        ],
        archive_sut_files: [
                "/var/log/puppetlabs/puppetserver/metrics.json",
                "/var/log/puppetlabs/puppetserver/gc.log",
                "/etc/sysconfig/puppetserver",
                "/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf"
        ],
        jruby_jar: "/opt/puppetlabs/server/apps/puppetserver/jruby-9k.jar",
        hocon_settings: [
                  [
                    file: "/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf",
                    path: "jruby-puppet.compile-mode",
                    value: "jit"
                  ]
        ],
        server_heap_settings: "-Xms2g -Xmx2g",
])
