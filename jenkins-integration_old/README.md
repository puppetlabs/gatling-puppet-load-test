## Jenkins Integration for Gatling Perf Testing

This sub project is divided as:

  * `beaker/`   -- provisioning steps written using Beaker's DSL
  * `bin/perf`  -- the jenkins integration runner
  * `config/`   -- json configuration files written that `bin/perf` and `simulation_runner` can understand
  * `Gemfile`   -- the jenkins integration Ruby dependencies
  * `README.md` -- this file
  * `scripts/`  -- scripts that `bin/perf` calls, these are largely wrappers around calling Beaker


