package com.puppetlabs.gatling.config

import com.puppetlabs.gatling.simulation.SimulationWithScenario

class Node(val simulationClass: Class[SimulationWithScenario],
            val numRepetitions: Int,
            val numInstances: Int,
            val rampUpDuration: Int) {}

object Node {
  def apply(simulationClass: Class[SimulationWithScenario],
            numRepetitions: Int,
            numInstances: Int,
            rampUpDuration: Int) =
    new Node(simulationClass,
              numRepetitions,
              numInstances,
              rampUpDuration)
}
