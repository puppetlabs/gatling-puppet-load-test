package com.puppetlabs.gatling.runner

import com.excilys.ebi.gatling.app.Gatling
import com.puppetlabs.gatling.config.PuppetGatlingConfig
import com.puppetlabs.gatling.runner.ConfigDrivenSimulation

/**
 * This object simply provides a `main` method that wraps
 * [[com.excilys.ebi.gatling.app.Gatling]].main, which
 * allows us to do some configuration and setup before
 * Gatling launches.
 */
object PuppetGatlingRunner {

  def main(args: Array[String]) {

    val config = PuppetGatlingConfig.initialize()

    // This is a pretty terrible hack, but because Gatling initializes
    // all of its configuration settings from system properties and/or
    // the gatling config file prior to loading any of our simulation
    // classes, the only way for us to be able to override these
    // settings with values from *our* config file is to do something
    // before Gatling itself gets loaded.  The choice is basically
    // limited to either dynamically writing out our own gatling.conf
    // file or overriding the handful of system properties that we
    // care about.  I chose the latter for now.


    // This sets the class for the simulation we want to run.
    val simClass: String = classOf[ConfigDrivenSimulation].getName
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
