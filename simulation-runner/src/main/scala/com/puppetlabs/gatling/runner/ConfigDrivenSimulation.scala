package com.puppetlabs.gatling.runner

import com.excilys.ebi.gatling.core.scenario.configuration.Simulation
import com.excilys.ebi.gatling.http.Predef._
import com.puppetlabs.gatling.config.PuppetGatlingConfig
import com.excilys.ebi.gatling.core.structure.ChainBuilder
import com.excilys.ebi.gatling.core.Predef.scenario

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
        val sim: SimulationWithScenario = n.simulationClass.newInstance()

        // this part is pretty gross.  There is no way to wrap a "repeat"
        // around the `scn` programmatically without using this
        // ChainBuilder/dropRight hack.  The Gatling authors said there
        // will be a slightly cleaner way to do this in the 2.x series.
        // In the meantime, I'd rather have this hack in this one place
        // than force us to edit each Simulation that we generate from
        // the recorder/proxy by hand to provide the 'repeat' functionality.
        scenario(n.simulationClass.getSimpleName).repeat(n.numRepetitions) {
          new ChainBuilder(sim.scn.actionBuilders.dropRight(1), null)
        }.users(n.numInstances)
          .ramp(n.rampUpDuration)
          .protocolConfig(httpConf)
  })

  setUp(scns.head, scns.tail:_*)
}
