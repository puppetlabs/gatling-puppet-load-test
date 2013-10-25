## What in the holy heck is up with all of these crazy config files?!

You may have noticed that there are tons of different kinds of (mostly-json) config files strewn all around this repo.  It probably seems crazy.  It probably is.  Maybe there's a way we can make it better... but for now, let's just talk through what they all are and what purposes they serve.

### In the beginning, there was Jenkins

The first type of config file that you may see is the kind that we reference in the Jenkins jobs.  Sometimes we in-line the contents directly into the bash steps of the jenkins jobs; other times, we'll have the jenkins jobs reference actual files that we've saved into this repo, such as [./jenkins-integration/config/sample-cobbler-job.json](sample-cobbler-job.json).

Here's an example:

    { "master": {
        "hostname": "puppet",
        "ip": "10.16.150.50"
      },
      "steps": [
        "cobbler-provision",
        {"install": "3.1"},
        {"simulate": {
            "id": "PE28_vanilla_5",
            "scenario": {
              "run_description": "PE28VanillaCent5, 1 instance, 1 repetition",
              "is_long_running": true,
              "nodes": [
                {
                  "node_config": "pe28_vanilla_cent5.json",
                  "num_instances": 1,
                  "ramp_up_duration_seconds": 1,
                  "num_repetitions": 1
                }]}}}]}

These files are intended to control the general flow of the jenkins jobs.  They specify some base information about where the master will be running, and then define a list of steps to perform to accomplish the performance test.

The keys that are supported in these config files are:

* `master`: required; value may be a string (which will be interpreted as both the name and address of the master node), or a map containing the keys "hostname" and "ip"--these can be used for cases where the hostname is not resolvable, etc.
* `ssh-keyfile`: optional; defaults to "~/.ssh/id_rsa".  This will be used for ssh connections to the various systems involved in the test.
* `sbtpath`: optional; The path to the sbt jar for launching the simulation; defaults to "/home/jenkins/sbt-launch.jar".
* `steps`: required; the list of steps to perform.  This is a JSON array.

Each item in the `steps` array can either be a single string (for steps that don't require any arguments), or a map whose key is the step name and whose value contains the parameters for the step.

Here's the list of supported steps:

* `cobbler-provision`: this will trigger a request to the cobbler controller box to have it set up the performance testing hardware for a netboot, and then reboot the performance box.  When the box comes back online it'll reinstall the operating system so that we start with a clean image.  This step currently doesn't accept any arguments because the cobbler logic is all hard-coded; in the future we might parameterize this if we have more than one box we can test against, and/or if we have different OS images available to test against.
* `install`: this step is used to install the puppet master.  Legal values are currently "3.1", "3.0", and "2.8", which refer to versions of PE that can be installed; in the future we will need to support an OSS master of some sort as well.  The "install" step will attempt to *uninstall* PE prior to installing it, which can theoretically allow us to test multiple versions of PE on the same machine w/o completely re-installing the OS; however, it'll always be safer to just do a full cobbler step and wipe the OS between installations of PE versions.
* `simulate`: this step will cause a single run of a gatling simulation.  You may end up having several "simulate" steps in a single job.

The value of the "simulate" step is a map.  It must contain an `id` key, which is simply a unique identifier for the simulation; it's used by Gatling to track the history of a particular simulation over time.  It can only consist of letters, numbers, and underscores.

It must also contain a key `scenario`, which is a map that contains the actual gatling configuration.  Here is some info about the keys for that map:

* `run_description`: this is simply some descriptive text about what the simulation is going to do.  It will show up in some of the HTML reports that are generated during the run, but it's purely cosmetic.
* `is_long_running`: this is a boolean, and is probably kind of poorly named.  What it does is toggle all of the simulated puppet agents between "attack" mode and "real world" mode.  In "real world" mode, each agent will sleep for 30 minutes between simulated runs; this gives us a better picture of what the load would look like in the default PE deployment configuration, but it will also cause the simulation run to take a lot longer.  In "attack" mode, each simulated agent will start a new agent run immediately upon completion of the previous one.  This can be used to generate a higher amount of load in a shorter period of time.  Typically, you're going to want to set 'is_long_running' to true, because it's more useful for us to be simulating the agent runs with the 30 minute sleeps, the way they would exist in the wild.
* `nodes`: this is a JSON array describing all of the agent nodes that should be simulated.  Putting more than one node into this array allows us to simulate load that would be generated by agents with different catalogs, rather than testing a single homogenous catalog.

Each `node` can contain the following keys:

* `node_config`: this is a reference to a pre-existing node configuration file that was generated alongside a Proxy Recorder session.  In other words, whenever we set up the Gatling proxy to record an agent run for use in future simulations, we also create a node configuration file that describes what we captured in that proxy recorder session.  We'll go into more detail on these node config files a little later; for now, suffice to say that the value of this key must reference an existing node config file that lives in the directory [./simulation-runner/config/nodes](./simulation-runner/config/nodes); e.g., [./simulation-runner/config/nodes/pe3_vanilla_cent5.json](./simulation-runner/config/nodes/pe3_vanilla_cent5.json).  For more info on the proxy recorder, check out the [./proxy-recorder/README.md](README).
* `num_instances`: this controls how many instances of this agent node will be simulated.
* `ramp_up_duration_seconds`: this is basically the splay period; the simulated agents will be kicked off at an even distribution over this amount of time.  e.g., if you set this to 30 mins and your `num_instances` is set to 30, then one new agent sim will be kicked off per minute for the first 30 mins of the run.
* `num_repetitions`: the number of simulated puppet agent runs that each simulated node must complete before exiting and completing the simulation.  You generally want this to be at least 2, so that you are letting all of the agents live through a full execution cycle and guaranteeing that you have a peak a mount of load somewhere in the middle of the run while they are all active.

That's about it for the jenkins config files.  Now we can move on to the node configuration files.

### Node simulation configuration files

Node simulation configuration files live in `simulation-runner/config/nodes`.  There should be exactly one of these for each Gatling simulation class that we generate with the Gatling proxy recorder (the gatling simulation classes live in `simulation-runner/src/main/scala/com/puppetlabs/gatling/node_simulations`).

If you're not familiar with the proxy recorder, please see [./proxy-recorder/README.md](the proxy recorder README).

Currently we build these by hand to correspond with whatever we did to set up the node before using the proxy recorder.  I think it should be possible to automate the proxy recorder and generation of these json files in the future; you could kick them off from a jenkins job and simply specify parameters for the list of modules/classes to use, and everything else should be automatable.  Some day...

Anyway, back to the present reality.  Here's an example of what a node config file looks like:

    {
        "certname": "pe-centos5.localdomain",
        "simulation_class": "com.puppetlabs.gatling.node_simulations.PE28BigTemplateHeavyCatalogCent5",
        "modules": [ { "name": "nwolfe/loadtest",
                       "version": "0.0.3",
                       "git": "git://github.com/shakedown/puppet-loadtest.git" },
                     { "name": "puppetlabs/apache",
                       "version": "0.6.0" },
                     { "name": "puppetlabs/firewall",
                       "version" : "0.3.1"} ],
        "classes": [ "loadtest::bigtemplateheavycatalog" ]
    }

And here are what the keys/values mean:

* `certname`: this *must* exactly match the certname of the agent node that you recorded using the gatling proxy recorder.  We use this to classify the node on the puppet master, and then when the gatling simulation runs it will send this up as part of the HTTP requests for the simulated agent run.  If they don't match *exactly* then the requests being sent by the gatling simulation will not trigger the right classes in the catalog on the master, and the simulation won't provide meaningful data.
* `simulation_class`: this is the name of the Scala class that was generated by the gatling proxy recorder.  They can be found in `simulation-runner/src/main/scala/com/puppetlabs/gatling/node_simulations`.  If the value you provide here doesn't match a class that exists there, the simulation will fail.
* `modules`: a list of puppet modules that need to be installed on the master in order to provide the classes that are used by the node that we're simulating.  Presumably, you installed these modules on your master by hand when you were preparing to do the proxy recording; this config just allows us to make sure those same modules are automatically installed on the master that we're using during the simulation runs.  More info on the format for specifying the modules in just a moment...
* `classes`: a list of puppet classes that should be applied to the simulated node.  During the setup phases of the simulation run, the node will be classified (via ENC or similar) with these classes; this is what will cause the catalog requests to exercise interesting catalogs during the simulation.  Each class in this list should be fully namespace-qualified.

Back to `modules` for a moment; each entry in your `modules` array should be a map.  Here are the keys for that map:

* `name`: required; the name of the module to install
* `version`: required; the version of the module to install
* `git`: optional; if this value is *not* provided, then the module will be installed from the forge, using the exact name and version specified above.  If this value *is* provided, then the module will be installed by cloning a git repo.  This value should specify the full git URL to a public git repo that contains the source code of the module, and assumes that there is a tag on the repo that exactly matches the `version` string specified above.

### OK, we're done here... right?

Well... kind of?  That should be all of the config files that you'll ever have to care about, but there is actually one more kind that you might encounter if you are ever doing hard core debugging on a simulation run.

You probably don't ever need to know about this, so feel free to stop reading now if you like.  :)

Still here?  OK, well, here's the scoop, then:

When we actually get to the point in the process where we're ready to launch the gatling simulations via sbt, we need a way to pass all of the relevant configuration data to scala/gatling.  It's not really possible to do this via command line arguments, so, we end up writing them to JSON config files.

These will be written out to the `simulation-runner/config/scenarios` directory.  To a large degree, the contents of these files will just be a subset of the jenkins config files.

I can add more docs on these later if they are relevant to anyone, but hopefully they'll just be invisible.

FIN



