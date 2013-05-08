package com.puppetlabs.gatling.simulation

import com.excilys.ebi.gatling.core.scenario.configuration.Simulation
import com.excilys.ebi.gatling.core.structure.ScenarioBuilder

abstract class SimulationWithScenario extends Simulation {
  val scn: ScenarioBuilder
}
