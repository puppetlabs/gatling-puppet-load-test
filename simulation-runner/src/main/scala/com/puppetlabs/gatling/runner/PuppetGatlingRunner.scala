package com.puppetlabs.gatling.runner

import com.excilys.ebi.gatling.app.Gatling
import com.puppetlabs.gatling.config.PuppetGatlingConfig

/**
 * This object simply provides a `main` method that wraps
 * [[com.excilys.ebi.gatling.app.Gatling]].main, which
 * allows us to do some configuration and setup before
 * Gatling launches.
 */
object PuppetGatlingRunner {

  def main(args: Array[String]) {

    val config = PuppetGatlingConfig.initialize()

    // This sets the class for the simulation we want to run.
    val simClass = classOf[ConfigDrivenSimulation].getName
    System.setProperty("gatling.core.simulationClass", simClass)

    // This sets the "id" for the simulataion, which will be used
    // as both a prefix for the output directory and as the main "title"
    // visible at the top of the HTML report.  You are basically
    // restricted to alphanumeric chars and underscores in this string.
    System.setProperty("gatling.core.outputDirectoryBaseName", config.simulationId)

    // This sets the "description" of the simulation, which is basically
    // just a slightly more detailed string describing the run.  It
    // appears just below the title in the HTML reports.
    System.setProperty("gatling.core.runDescription", config.runDescription)

    Gatling.main(args);
  }
}
