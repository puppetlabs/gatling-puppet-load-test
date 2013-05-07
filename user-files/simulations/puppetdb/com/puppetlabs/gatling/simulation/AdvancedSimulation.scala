package com.puppetlabs.gatling.simulation

import com.excilys.ebi.gatling.core.scenario.configuration.Simulation
import com.excilys.ebi.gatling.http.Predef._

class AdvancedSimulation extends Simulation {
  val httpConf = httpConfig
    .baseURL("https://pe-ubuntu-lucid:8140")
    .acceptHeader("pson, b64_zlib_yaml, yaml, raw")
    .connection("close")

  setUp(new PuppetDB().scn.users(10).ramp(100).protocolConfig(httpConf))
}
