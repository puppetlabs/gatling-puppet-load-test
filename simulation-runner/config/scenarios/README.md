## Scenario configuration files

This directory contains "scenario" configuration files.  These files are used to
describe an actual gatling run; they reference one or more
["node" config files](../nodes) to determine which agent recordings to play
back, and they also set up the parameters for each type of agent/node (e.g. how
many instances of that node to simulate simultaneously, etc.).

### File format

Here is an example "scenario" configuration file:

```json
{
    "run_description": "'medium' role from perf control repo",
    "nodes": [
        {
            "node_config": "PECouchPerfMedium.json",
            "num_instances": 1250,
            "ramp_up_duration_seconds": 1800,
            "num_repetitions": 4,
            "sleep_duration_seconds": 1800
        }
    ]
}
```

Here is a breakdown of the fields:

* `run_description`: a string with a basic description of the scenario.  Will show up in a few places, e.g. the
  Gatling report HTML, but can be anything you like.
* `nodes`: an array of one or more types of nodes/puppet agents to simulate.  Each node/agent entry is a map with the
  following keys:
** `node_config`: this is the name of the node config json file in [the `../nodes` directory](../nodes).  This ends up
   providing us with the information about how to create and classify a node group for this node, as well as indicating
   which Gatling recording we should be playing back.
** `num_instance`: this tells gatling how many concurrent instances of this particular node to simulate.  This is basically
   equivalent to specifying the number of agents that will be running against our Puppet Server instance during the test.
** `ramp_up_duration_seconds`: this is akin to puppet's `splay` setting.  Gatling will spread out the initial launching
   of the simulated agents, evenly, over this amount of time.  We typically set this to 30 minutes (1800 seconds), meaning
   that the load will be distributed roughly evenly over a 30-minute interval, because this mimic's the puppet agent's
   default behavior.
** `sleep_duration_seconds`: how long each simulated agent should sleep after completing a run, before it starts its
   next run.  We usually set this to 30 minutes (1800 seconds) as well (except for during development), because that
   setting mimic's the puppet agent's default behavior.
** `num_repetitions`: this tells gatling how many times each simulated agent should run before exiting.  We often use
   this value just to control how long we want the test to run; e.g., if the "ramp up" and "sleep" settings are set to
   30 minutes, and we want the test to run for a total of 2 hours, we would set this to 4.
