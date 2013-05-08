package com.puppetlabs.gatling.config

import scala.util.parsing.json.JSON
import com.puppetlabs.json.{JsonInt, JsonList, JsonString, JsonMap}
import com.puppetlabs.gatling.simulation.SimulationWithScenario

class Config(configFilePath: String) {

  private val Some(JsonMap(config)) = JSON.parseFull(io.Source.fromFile(configFilePath).mkString)

  private val JsonList(jsonNodes) = config("nodes")

  val JsonString(baseUrl) = config("base_url")

  val nodes = jsonNodes.map((n) => {
    val JsonMap(node) = n
    val JsonString(simClass) = node("simulation_class")
    val JsonInt(numInstances) = node("num_instances")
    val JsonInt(numRepetitions) = node("num_repetitions")
    val JsonInt(rampUpDuration) = node("ramp_up_duration_seconds")
    Node(Class.forName(simClass).asInstanceOf[Class[SimulationWithScenario]], numRepetitions, numInstances, rampUpDuration)
  })
}


object Config {
  def apply(configFilePath: String) = new Config(configFilePath)
}
