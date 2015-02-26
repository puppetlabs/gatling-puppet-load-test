package com.puppetlabs.gatling.runner

import io.gatling.core.scenario.Simulation
import io.gatling.core.structure.ScenarioBuilder

/**
 * This class is a bit of a shim; it just exposes the `scn`
 * property that all of the Recorder-generated Simulations
 * define, so that we can access that member from our
 * [[com.puppetlabs.gatling.runner.ConfigDrivenSimulation]]
 * code w/o having to know the exact types of the
 * Simulation classes.  Currently this means that all
 * the Recorder-generated sim classes need to be modified
 * by hand to specify that they inherit from this class.
 */
abstract class SimulationWithScenario extends Simulation {
  val scn: ScenarioBuilder
}
