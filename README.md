## Wecome to load testing Puppet with Gatling!

This is the main Puppetlabs laod testing repository for it's http services. The repository is currently split into three projects:

  1. `proxy_recorder` -- This is the shell based tool to record http interactions of a client against a server so they can be re-used as a Gatling load testing scenario.
  2. `simulation_runner` -- This is the tool to replay the recorded scenarios as a preconfigured simulation run using Gatling.
  3. `jenkins_integration` -- This project leverages Beaker to provision new environments in Puppetlabs' Jenkins infrastructure that are suitable for being load tested using `simulation_runner`.
