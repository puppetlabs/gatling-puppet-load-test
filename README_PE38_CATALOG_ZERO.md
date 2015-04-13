# Manual steps for setting up PE 3.8 agent / catalog-zero simulation

This readme captures the basic steps that we followed to generate a simulation
file with a Puppet Enterprise 3.8 master and a corresponding PE agent
classified to include the catalog-zero class, from https://github.com/puppetlabs/test-catalogs/blob/b0dd2765dd3ed55c737c50ab86d970836a93d986/catalog-zero/modules/catalog-zero/manifests/init.pp.

## Basic environment setup

1. Did a monolithic install of PE on a fresh master node.

2. Pulled down the content from https://github.com/puppetlabs/test-catalogs/tree/b0dd2765dd3ed55c737c50ab86d970836a93d986/catalog-zero/modules
   and copied into the `/etc/puppetlabs/puppet/environments/production/modules`
   directory on the PE master.  So directories like `/etc/puppetlabs/puppet/environments/production/modules/catalog-zero`
   were now present on the master.

3. Logged into the PE console UI in a web browser.

4. Navigated to the Classification tab.

5. Created a new "Node group name" called "catalog-zero" and pressed the
   "Add group" button.

   Note that we went with adding the simulated agent and catalog-zero class
   to a new node group rather than just adding the catalog-zero class to an
   existing node group because we didn't want the agent running on the master
   to pick up the catalog-zero class.  catalog-zero configures a number of
   "bogus" repositories - with mirrorlists like "http://yumrepocatalog-zero10-impl12.foobar.com".
   The presence of these causes errors to occur when the agent is being run
   from the PE master itself - presumably because it tries to resolve those
   bogus repositories to install some components that are needed on the master? -
   which could adversely affect timing / load for a "normally functioning
   agent" scenario.  No such errors have been observed for a vanilla external,
   i.e., not running on the master, PE agent classified to use catalog-zero.

5. Navigated into the "catalog-zero" node group.

6. Under the "Rules" tab, entered a "certname" and pressed the "Pin node" button
   for each agent involved in the simulation.  Pressed the "Commit 1 change"
   button to commit the change.

7. Navigated to the "Classes" tab.  In the "Add new class" box, entered
   "catalog-zero" and press the "Add class" button.  Pressed the "Commit 1
   change" button to commit the change.

8. Modify the PE master's `auth.conf` file to allow all client requests.

   This was necessary to avoid the need for the simulation requests to include
   hostnames in the payload which match the subject name on the client
   certificate being used to make SSL connections.  If we were guaranteed that
   the hostname on the client certificate and the payload were always matching,
   this step probably wouldn't have been necessary.  Since the certname that we
   used to record the simulation may not match the one that we use when
   replaying against a different PE master, though, this step makes the setup
   easier.

   This involves changing the entire contents of the `/etc/puppetlabs/puppet/auth.conf`
   file to:

   ~~~~ini
   path /
   auth any
   allow *
   ~~~~

   After this change is made, the `pe-puppetserver` service should be restarted.
   For example, depending upon your distribution:

   ~~~~
   service pe-puppetserver restart
   ~~~~

9. On a separate fresh node, installed the PE agent.

   ~~~~
   curl -k https://thepemaster:8140/packages/current/install.bash | sudo bash
   ~~~~

10. Did a puppet agent run:

   ~~~~
   puppet agent --test --server thepemaster
   ~~~~

   A number of "catalog-zero" specific messages appeared in the output.
   For example:

   ~~~~
   Notice: Hello! catalog-zero10-impl84!
   Notice: /Stage[main]/Catalog-zero10::Impl::Catalog-zero10-impl8/Notify[Hello! catalog-zero10-impl84!]/message: defined 'message' as 'Hello! catalog-zero10-impl84!'
   ~~~~

11. Did a couple of more agent runs.

   These allowed the initial set of resources to all be applied before we moved
   on to capturing an agent run simulation.  For simulation replay, we're
   interested in the "stable state" behavior that an agent would perform rather
   than all of the one-time activities that the agent would perform, e.g.,
   initial file_content requests for file resources, as the latter would not be
   a useful representation of the requests that an agent would make for repeated
   runs against a master over a long period of time.

## Initial agent capture and simulation

1. Followed the steps in the [proxy-recorder README] (proxy-recorder/README.md)
   to generate a simulation file, using the PE master and PE agent that were
   previously setup.

2. Followed the steps in the [simulation-runner README] (simulation-runner/README.md)
   to modify the simulation file for future replay, setup scenario files for
   future playback, and perform a pilot simulation run.

3. Filed a PR to commit the simulation artifacts to this repo.  The artifacts
   included:

   * [Scala simulation file] (simulation-runner/src/main/scala/com/puppetlabs/gatling/node_simulations/PE38CatalogZero.scala)
   * [pe38-catalogzero scenario files] (simulation-runner/config/scenarios/)
   * [Report request body] (simulation-runner/user-files/bodies/PE38CatalogZero_0107_request.txt)

## Setup clean environment for new simulation playback

1. Followed all of the steps in the [Basic environment setup](#basic-environment-setup)
   section.

2. As described in the [simulation-runner README] (simulation-runner/README.md)
   file, ran the `retrieve-agent-ssl-certs.sh` script to retrieve SSL files
   from the agent being simulated.

3. In the `simulation-runner` directory, created a Python script, `script.py`,
   to run the desired simulation file in an endless while loop.  Contents of the
   file included:

   ~~~~python
   from subprocess import call

   # run this from gatling-puppet-load-test<targetsystem>/simulation-runner

   while 1:
        call("PUPPET_GATLING_SIMULATION_CONFIG=\"config/scenarios/pe38-catalogzero-1000.json\" PUPPET_GATLING_SIMULATION_ID=PE38_CatZero_2_1000a_1800s PUPPET_GATLING_MASTER_BASE_URL=https://perf-bl15.delivery.puppetlabs.net:8140 sbt run", shell=True)
   ~~~~

   For a more bounded simulation, the while could be changed to a for loop, e.g.,
   "for r in range(X)" or the "num_repetitions" setting in the json simulation
   configuration file could be changed to a more appropriate value.

4. Run the Python script, e.g., `python ./script.py`.
