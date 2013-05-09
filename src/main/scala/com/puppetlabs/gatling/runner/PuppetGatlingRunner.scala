package com.puppetlabs.gatling.runner

import com.excilys.ebi.gatling.app.Gatling
import com.puppetlabs.gatling.config.PuppetGatlingConfig

object PuppetGatlingRunner {

  def main(args: Array[String]) {

    val config = PuppetGatlingConfig.initialize("/home/cprice/work/gatling_scratch/git/gatling-puppet-scale-test/config/sample_scenario_config.json")




    Gatling.main(args);
  }
}
