import groovy.io.FileType
import java.nio.file.Paths

class DSLHelper {
    PrintStream out;

    DSLHelper(out) {
        this.out = out
    }
    def overrideParameterDefault(job, param_name, new_default_value) {
        this.out.println("\tAttempting to override '${param_name}' default value to '${new_default_value}' for job '${job.name}'")

        // NOTE: HACK.  for some reason, the 'configure' block may get called
        //  several times.  See https://issues.jenkins-ci.org/browse/JENKINS-39417 .
        // Worse, it seems like on the subsequent calls to the configure block,
        // the state of the job is reset to still include the original parameter
        // data.  It seems harmless to simply execute the overrides multiple times,
        // but logging the messages about the overrides multiple times looks very
        // confusing in the seed job output.  By closing over this local variable,
        // we can make sure the log messages only show up once, which makes
        // the seed job output a little less confusing.
        def param_checked = false

        job.with {
            configure { Node project ->
                    Node node = project / 'properties' / 'hudson.model.ParametersDefinitionProperty' / 'parameterDefinitions'
                    def result = node.children().find { child ->
                        def my_name_node = child.get("name")
                        def my_default_value_node = child.get("defaultValue")
                        def my_name = my_name_node[0].value()
                        if (my_name == param_name) {
                            def old_value = my_default_value_node[0].value()
                            my_default_value_node[0].setValue(new_default_value)
                            if (!param_checked) {
                                out.println("\tParameter '${param_name}' found, default value changed from '${old_value}' to '${new_default_value}'")
                            }
                            return true
                        }
                        return false
                    }
                    if (! result) {
                        if (!param_checked) {
                            out.println("\tWARNING!! Parameter '${param_name}' not found, ignoring attempt to override!")
                        }
                    }
                    param_checked = true
            }
        }
    }
}

// NOTE: these determine the default repo/branch that the seed job will
// poll to look for Jenkinsfiles.  For production they should always
// be set to the PL gplt repo's master branch.  For dev, you may want
// to change them to point to your fork or your git daemon (though you can
// accomplish the same by simply modifying the values in the Jenkins gui
// on the 'configuration' screen for the seed job.

def git_repo = 'https://github.com/puppetlabs/gatling-puppet-load-test.git'
def git_branch = 'master'

String relativize(File root_dir, File f) {
    Paths.get(root_dir.absolutePath).relativize(Paths.get(f.absolutePath))
}

dir = new File(__FILE__).parentFile.absoluteFile

def root_dir = dir
while (root_dir.name != "jenkins-integration") {
    root_dir = root_dir.parentFile
}
root_dir = root_dir.parentFile
scenarios_dir = new File(dir, "scenarios")

def helper = new DSLHelper(out);

scenarios_dir.eachFileRecurse (FileType.FILES) { file ->
    if (file.name.equals("Jenkinsfile")) {
        job_prefix = file.parentFile.name
        relative_jenkinsfile = relativize(root_dir, file)

        def job = workflowJob(job_prefix) {
            // TODO: this should be moved into the Jenkinsfile by use of
            // the 'properties' step, see https://issues.jenkins-ci.org/browse/JENKINS-32780,
            // or alternately it could be handled in the JobDSL.groovy files alongside
            // each Jenkinsfile.
            parameters {
                stringParam('SUT_HOST',
                        'foo-sut.delivery.puppetlabs.net',
                        'The host/IP address of the system to use as the SUT')
                booleanParam('SKIP_SERVER_INSTALL', false, 'If checked, will skip over the PE/OSS Server Install step.  Useful if you are doing development and already have a server SUT.')
                booleanParam('SKIP_PROVISIONING', true, 'If checked, will skip over the Razor provisioning step.  Useful if you already have an SUT provisioned, e.g. via the VM Pooler.')
            }
            definition {
                cpsScm {
                    scm {
                        git {
                            remote {
                                url(git_repo)
                            }
                            branch(git_branch)
                        }
                    }
                    scriptPath(relative_jenkinsfile)
                }
            }
            // Default number of builds to retain history for.  This can be overridden
            // for specific jobs by creating a JobDSL.groovy file alongside the Jenkinsfile.
            logRotator {
                numToKeep(50)
            }
        }

        jobdslfile = new File(scenarios_dir, "${job_prefix}/JobDSL.groovy")
        if (jobdslfile.isFile()) {
            out.println("Found JobDSL script: '${jobdslfile.getAbsolutePath()}', executing")
            def engine = new GroovyScriptEngine('.')
            engine.run(jobdslfile.getAbsolutePath(),
                    new Binding([job: job,
                                 out: out,
                                 helper: helper])
            )
        }
    }

}
