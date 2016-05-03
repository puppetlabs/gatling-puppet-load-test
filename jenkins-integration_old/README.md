# OLD STUFF

This is the old directory where we had done our original jenkins stuff
several years ago.  It's almost certainly all bit-rot at this point, and
will probably be deleted soon.

## Jenkins Integration for Gatling Perf Testing

This sub project is divided as:

  * `beaker/`   -- provisioning steps written using Beaker's DSL
  * `bin/perf`  -- the jenkins integration runner
  * `config/`   -- json configuration files written that `bin/perf` and `simulation_runner` can understand
  * `Gemfile`   -- the jenkins integration Ruby dependencies
  * `README.md` -- this file
  * `scripts/`  -- scripts that `bin/perf` calls, these are largely wrappers around calling Beaker


