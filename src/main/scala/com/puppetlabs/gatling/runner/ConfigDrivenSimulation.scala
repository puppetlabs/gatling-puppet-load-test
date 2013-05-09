package com.puppetlabs.gatling.runner

import com.excilys.ebi.gatling.core.scenario.configuration.Simulation
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.core.config.GatlingConfiguration
import com.puppetlabs.gatling.config.PuppetGatlingConfig
import com.puppetlabs.gatling.runner.SimulationWithScenario

/**
 * This class is the "main" Simulation class that we'll always point
 * Gatling at.  It's job is to wrap one or more puppet node simulations
 * based on the configuration specified in the config file
 */
class ConfigDrivenSimulation extends Simulation {

  val config = PuppetGatlingConfig.configuration

  val httpConf = httpConfig
    .baseURL(config.baseUrl)
    .acceptHeader("pson, b64_zlib_yaml, yaml, raw")
    .connection("close")

  val scns = config.nodes.map((n) => {

    val sim: SimulationWithScenario = n.simulationClass.getConstructor(classOf[Int]).newInstance(n.numRepetitions: java.lang.Integer)
      sim.scn
      .users(n.numInstances)
      .ramp(n.rampUpDuration)
      .protocolConfig(httpConf)
  })

  setUp(scns.head, scns.tail:_*)
}
