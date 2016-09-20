## Welcome to load testing Puppet with Gatling!

NOTE: recent versions of Puppet Server and PE require some manipulation of the tk-auth rules in order to get proxy recordings and simulations to work properly.  For more info, see [README_tk_auth.md](./README_tk_auth.md).

This is the main Puppetlabs load testing repository for its http services. The repository is currently split into three projects:

  1. `proxy_recorder` -- This is the shell based tool to record http interactions of a client against a server so they can be re-used as a Gatling load testing scenario.
  2. `simulation_runner` -- This is the tool to replay the recorded scenarios as a preconfigured simulation run using Gatling.
  3. `jenkins_integration` -- This project leverages Beaker to provision new environments in Puppetlabs' Jenkins infrastructure that are suitable for being load tested using `simulation_runner`.

Note that the state of the various config files required by all the parts of this system is a bit chaotic and confusing; hopefully we can figure out some ways to simplify it going forward, but for now, see [./README_CONFIG_FILE_MADNESS.md](README_CONFIG_FILE_MADNESS.md) for some info on the current state of affairs.
