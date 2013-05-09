package com.puppetlabs.gatling.simulation

import com.excilys.ebi.gatling.core.scenario.configuration.Simulation
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.core.config.GatlingConfiguration
import com.puppetlabs.gatling.config.PuppetGatlingConfig

class AdvancedSimulation extends Simulation {

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

  println( "Getting ready to run sim.  Config:" + GatlingConfiguration.configuration)

//  throw new IllegalStateException("hi")
  setUp(scns.head, scns.tail:_*)
}
