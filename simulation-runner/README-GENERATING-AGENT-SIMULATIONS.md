# Modifying a generated agent simulation for replay

This readme has some information about the steps required to alter a recorded
simulation, i.e., the scala simulation and associated files commonly generated
via the proxy-recorder tool, in order to make the simulation compatible with the
puppet-gatling-jenkins-plugin project.

## NOTE re ruby script to automate some of these steps

There is a ruby script in the proxy-recorder directory that will apply most of
these changes.  (*NOTE: requires ruby 2.0 or greater.*)

Just run `ruby ../proxy-recorder/process_gatling_recording.rb
$path_to_scala_file` and it will output the modified scala to a file named
after the input file with .new added. So an updated `MySimulation.scala` would
be called `MySimulation.scala.new`. The script does not apply Step 13, but does
do the rest of the changes below.

In the future we'd like to be able to fully automate the agent recording process
so that we can set up jenkins jobs to take new recordings when a new version
of PE is released.  However, to do that, we really need to get to a state where
the recorder can generate the simulation in another format besides raw scala
code.  I've discussed this briefly with the Gatling maintainers and it seems
like it shouldn't be a huge chunk of work to submit a patch upstream that
would allow you to generate JSON output for a recording instead of scala.  Then
we will be able to do some post-processing on the JSON, and then feed the modified
JSON back into a Gatling API to have it generate the Scala.  This is something
I'm hoping to poke at after we've gotten to the point where the *execution* of
a simulation is fully automated.

## Changes to the simulation scala file

1. Look for any references to "inferHtmlResources" or the "resources" method.

  If you find any of these, it means that you probably left the
  "Infer Html resources?" box checked in the Gatling proxy recorder GUI when you
  generated the simulation file.  This causes the simulation to try to behave
  like a browser and request multiple 'resources' in parallel; this behavior is
  not suitable for simulating puppet agents.  Please re-record your scenario with
  the 'Infer Html resources?' checkbox *unchecked*.

2. Change the package name to:

  ~~~~scala
  package com.puppetlabs.gatling.node_simulations
  ~~~~

3. Add the following import statements:

  ~~~~scala
  import com.puppetlabs.gatling.runner.SimulationWithScenario
  import org.joda.time.LocalDateTime
  import org.joda.time.format.ISODateTimeFormat
  ~~~~

4. Optional: Remove the jdbc import.

  ~~~~scala
  //import io.gatling.jdbc.Predef._
  ~~~~

  This didn't seem to make a difference in any simulation runs I tried, but the
  import didn't seem to be used.

5. Change the simulation class to extend `SimulationWithScenario`:

  ~~~~scala
  class MySimulation extends SimulationWithScenario {
  ~~~~

6. Comment out the `httpProtocol` variable definition:

   ~~~~scala
   //	val httpProtocol = http
   //		.baseURL("https://myhost.localdomain:8140")
   //		.acceptHeader("pson, b64_zlib_yaml, yaml, raw")
   //		.acceptEncodingHeader("identity")
   //		.contentTypeHeader("application/x-www-form-urlencoded")
   //		.userAgentHeader("Ruby")
   ~~~~

   For an example of this change, see this commit:
   https://github.com/puppetlabs/gatling-puppet-load-test/commit/2b54e20f724ca25184f7f7b9e9a4b41b63439485.

7. To the `headers_` variable which is used by the report request, add a
   "Connection: close" header.

  For agent runs in the Puppet 3.7.X series and above, each of the requests is
  made across the same socket connection.  The agent may not send a
  "Connection: close" header on the last request sent to the master and instead
  may just drop the connection after processing the response to the last request.
  The behavior of dropping the connection from the client isn't something which
  is reflected in a captured simulation - and may not be possible to inject
  directly into the simulation file source code.  The addition of a
  "Connection: close" header to the simulation file is a compromise which should
  lead to the socket connection not persisting beyond the set of requests for an
  individual simulation run.  This obviously isn't ideal in that it would differ
  from a real-world agent run.

  ---

  For example, the following code changes would need to be made:

  ~~~~scala
  val headers_107 = Map(
    "Accept" -> "pson, yaml",
    "Content-Type" -> "text/pson",
    "Connection" -> "close")

  ...
  val chain_1 = exec(http("request_97")
  ...
    .exec(http("request_107")
      .put("/production/report/myhost.localdomain")
      .headers(headers_107)
      .body(RawFileBody("MySimulation_0107_request.txt")))
  ~~~~

  For an example of the above changes, see this commit:
  https://github.com/puppetlabs/gatling-puppet-load-test/commit/a5cff8b3ab501f7ce300fd128db83cf389960659.

8. Comment out the definition of the `uri1` variable:

  ~~~~scala
  // val uri1 = "https://myhost.localdomain:8140/production"
  ~~~~

  For an example of this change, see this commit:
  https://github.com/puppetlabs/gatling-puppet-load-test/commit/2b54e20f724ca25184f7f7b9e9a4b41b63439485.

9. In the body of the catalog request, bump the year in the "expiration" element
   up to a value that is at a time significantly out in the future:

  Without this change, if the current time on the Puppet server processing the
  report is later than the "expiration" in the report, an HTTP 400 error would be
  returned from the server, with a message like the following being written into
  the `/var/log/puppetserver/puppetserver.log` file:

  ~~~~
  2015-04-08 00:41:57,296 ERROR [puppet-server] Puppet Attempt to assign to a reserved variable name: 'trusted' on node myhost.localdomain
  ~~~

  Note that this error is being tracked in this ticket:
  https://tickets.puppetlabs.com/browse/PE-8469.

  ---

  ~~~~scala
  val chain_0 = exec(http("request_0")
  ...
    .exec(http("catalog")
      .post("/production/catalog/myhost.localdomain")
      .headers(headers_3)
      .formParam("facts_format", "pson")
      .formParam("facts", "%7B%22name%22%3A%22myhost.localdomain...
        expiration%22%3A%222025-04-08...")
  ~~~~

  In the above example, the original value for the "expiration" element included
  a year of "2015" but was bumped up to "2025".  The only change in the code
  above from what was originally generated was that the "1" in "2015" was
  replaced with a "2".

  For an example of this change, see this commit:
  https://github.com/puppetlabs/gatling-puppet-load-test/commit/2b54e20f724ca25184f7f7b9e9a4b41b63439485.

10. Presuming you want to control the simulation parameters through a scenario
    json file rather than hardcoding them in the Scala file directly, comment
    out the generated call to setup():

  ~~~~scala
  // setUp(scn.inject(atOnceUsers(1))).protocols(httpProtocol)
  ~~~~

  For an example of this change, see this commit:
  https://github.com/puppetlabs/gatling-puppet-load-test/commit/2b54e20f724ca25184f7f7b9e9a4b41b63439485.

11. In order for Gatling to generate useful reports per request endpoint, the
    names of the endpoints should be renamed.

  | Name                 | Legacy Endpoint                                            | Modern v3 Endpoint                                              |
  | -------------------- | ------------                                               | ------------                                                    |
  | catalog              | /production/catalog/agent.localdomain                      | /puppet/v3/catalog/agent.localdomain                            |
  | filemeta pluginfacts | /production/file_metadatas/pluginfacts                     | /puppet/v3/file_metadatas/pluginfacts                           |
  | filemeta plugins     | /production/file_metadatas/plugins                         | /puppet/v3/file_metadatas/plugins                               |
  | filemeta             | /production/file_metadatas/modules/xyz                     | /puppet/v3/file_metadata/modules/xyz                            |
  | filemeta mco plugins | /production/file_metadatas/modules/pe_mcollective/plugins  | /puppet/v3/file_metadata/modules/puppet_enterprise/mcollective  |
  | node                 | /production/node/agent.localdomain                         | /puppet/v3/node/agent.localdomain                               |
  | report               | /production/report/agent.localdomain                       | /puppet/v3/report/agent.localdomain                             |

  To change this for the "node" request, for example, the argument to the
  http() method would need to be changed from "request_0" to "node":

  ~~~~scala
  val chain_0 = exec(http("node")
    .get("/production/node/myhost.localdomain?transaction_uuid=2eabf4c0-acf8-466f-a0e4-d75519be6afc&fail_on_404=true"))
  ~~~~

12. Add a dynamic timestamp to the report payload.

  This change is needed whenever the report processor registered with the Puppet
  master would somehow reject the report content based on the same timestamp
  being seen on multiple reports for the same agent.  PuppetDB, for example,
  will reject a report for this case.  The report rejection may look like this in
  the `/var/log/puppetdb/puppetdb.log` file:

  ~~~~
  2015-04-08 15:22:41,220 ERROR [c.p.p.command] [b2d63e54-b201-46ab-9095-a122fcf5b857] [store report] Retrying after attempt 4, due to: org.postgresql.util.PSQLException: ERROR: duplicate key value violates unique constraint "reports_pkey"
    Detail: Key (hash)=(4f049f868926a9cb0d175a9f971b0f6b0732a1ba) already exists.  org.postgresql.util.PSQLException: ERROR: duplicate key value violates unique constraint "reports_pkey"
  ~~~~

  Note that the report PUT would likely still return a successful response to
  the simulated agent for this case but the artificial PuppetDB failures could
  invalidate the simulation.

  --

  The originally generated file should have some code for the report request
  which looks like:

  ~~~~scala
  val chain_1 = exec(http("request_97")
  ...
    .exec(http("request_107")
      .put("/production/report/myhost.localdomain")
      .headers(headers_107)
      .body(RawFileBody("MySimulation_0107_request.txt")))
  ~~~~

  The "request.txt" file, which contains the payload of the report request body,
  should be loaded via an ELFileBody and a session variable named
  "reportTimestamp" should be set with a string representation of the current
  date/time when the simulation is being run.

  Prior to the "chain" variable in which the report request is defined, the
  following should be added:

  ~~~~scala
  val reportBody = ELFileBody("MySimulation_0107_request.txt")
  ~~~~

  The session variable should be defined and reportBody updated in the report
  request:

  ~~~~scala
  import org.joda.time.LocalDateTime
  import org.joda.time.format.ISODateTimeFormat
  import java.util.UUID

  ...

  val chain_1 = exec(http("request_97")
  ...
    .exec((session:Session) => {
      session.set("reportTimestamp",
        LocalDateTime.now.toString(ISODateTimeFormat.dateTime()))
    })
    .exec((session:Session) => {
      session.set("transactionUuid",
        UUID.randomUUID().toString())
    })
    .exec(http("request_107")
      .put("/production/report/myhost.localdomain")
      .headers(headers_107)
      .body(reportBody))
  ~~~~

  Along with the above changes to the Scala file, a reference to the
  "reportTimestamp" and "transactionUuid" variables should be added to the
  "request.txt" file.  For example, the original file may have:

  ~~~~json
  {"host":"myhost.localdomain","time":"2015-04-07T17:24:25.927023581-07:00",...,"transaction_uuid":"558b70db-554b-4497-ad85-ca63a299807f"},...}
  ~~~~

  This would need to be changed to:

  ~~~~json
  {"host":"myhost.localdomain","time":"${reportTimestamp}",...,"transaction_uuid":"${transactionUuid}",...}
  ~~~~

  For an example of the above changes, see this commit:
  https://github.com/puppetlabs/gatling-puppet-load-test/commit/9450847e52bd436192278a5fe9ea50308e4ddb26

13. In order to make the simulation more realistic, the driver program will automatically
    replace occurrences of the variable `${node}` in Strings with a dynamically
    generated node name (using a Gatling 'feeder' under the hood).
    The scala file and the report body in the request.txt file will both have multiple
    references to the certname of the agent that was used to make the original recording;
    you'll need to do a find and replace in those files and replace the occurrences
    of the certname (e.g. `vszab9lhwyarzky.delivery.puppetlabs.net`) with `${node}`.


## Request bodies

Gatling generates txt files to store the body of each post request. These will
have to be moved to appropriate paths before the simulation can be used.  As of
this update, this would be in the `user-files/bodies` subdirectory under the
location where this document resides.

## Dependencies

The target Puppet master must have gcc and make installed in order for some
gems, required by beaker, to compile.

## Future

* Nice to have: rename requests
* Nice to have: generate unique node names to avoid possible cert caching perf
  discrepancies
