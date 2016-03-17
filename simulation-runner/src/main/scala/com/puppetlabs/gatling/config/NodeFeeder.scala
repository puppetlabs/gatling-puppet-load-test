package com.puppetlabs.gatling.config

object NodeFeeder {
  def apply(certnamePrefix: String,
            numInstances: Int) =
    Range(1,numInstances).map(i => {Map("node" -> (certnamePrefix + i.toString))})
}
