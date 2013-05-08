package com.puppetlabs.gatling.simulation

import com.excilys.ebi.gatling.core.scenario.configuration.Simulation
import com.excilys.ebi.gatling.http.Predef._
import com.puppetlabs.gatling.config.Config

class AdvancedSimulation extends Simulation {
  val config = Config("/home/cprice/work/gatling_scratch/git/gatling-puppet-scale-test/config/sample_scenario_config.json")

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
