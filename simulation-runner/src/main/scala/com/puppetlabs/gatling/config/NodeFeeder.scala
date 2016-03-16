package com.puppetlabs.gatling.config

object NodeFeeder {
  def apply(certnamePrefix: String,
            numInstances: Int) =
    (1 to numInstances).map(i => {Map("node" -> (certnamePrefix + i.toString))})
}
