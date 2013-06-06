package com.puppetlabs.gatling.runner

import com.excilys.ebi.gatling.core.scenario.configuration.Simulation
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import bootstrap._
import com.puppetlabs.gatling.config.PuppetGatlingConfig

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

  val scns = config.nodes.map(node => {

    import node._

    val sim: SimulationWithScenario = simulationClass.newInstance

    scenario(simulationClass.getSimpleName)
      .repeat(numRepetitions) {
        exec(sim.scn)
      }.users(numInstances)
      .ramp(rampUpDuration)
      .protocolConfig(httpConf)
  })

  scns.foreach(setUp(_))
}
