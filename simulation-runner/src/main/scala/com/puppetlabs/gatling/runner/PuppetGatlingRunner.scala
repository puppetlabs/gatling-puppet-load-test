package com.puppetlabs.gatling.runner

import com.puppetlabs.gatling.config.PuppetGatlingConfig
import io.gatling.app.Gatling
import io.gatling.core.config.GatlingPropertiesBuilder

/**
 * This object simply provides a `main` method that wraps
 * [[io.gatling.app.Gatling]].main, which
 * allows us to do some configuration and setup before
 * Gatling launches.
 */
object PuppetGatlingRunner {

  def main(args: Array[String]) {

    val config = PuppetGatlingConfig.initialize()

    // This sets the class for the simulation we want to run.
    val simClass = classOf[ConfigDrivenSimulation].getName

    val props = new GatlingPropertiesBuilder
    props.sourcesDirectory("./src/main/scala")
    props.binariesDirectory("./target/scala-2.11/classes")
    props.simulationClass(simClass)
    props.runDescription(config.runDescription)
    props.outputDirectoryBaseName(config.simulationId)

    // This checks the values set in gatling_kickoff.rb
    if (sys.env("PUPPET_GATLING_REPORTS_ONLY") == "true") {
      props.reportsOnly(sys.env("PUPPET_GATLING_REPORTS_TARGET"))
    }

    Gatling.fromMap(props.build)

  }
}
