package com.puppetlabs.gatling.node_simulations

import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import akka.util.duration._
import com.puppetlabs.gatling.runner.SimulationWithScenario
import com.puppetlabs.gatling.config.{Node, PuppetGatlingConfig}
import bootstrap._

class PE3VanillaCent5LongRunning extends SimulationWithScenario {

  // TODO: refactor this "longrunning" stuff into a base class, it's
  // duplicated in all of the LongRunning sims right now.

  // Here we dig into the configuration object and find the number of repetitions
  // that were configured for this particular simulation class.
  val totalNumReps = PuppetGatlingConfig.configuration.nodes.find((n:Node) => n.simulationClass == this.getClass).get.numRepetitions

  val REPETITION_COUNTER: String = "repetitionCounter"


	val httpConf = httpConfig
			.baseURL("https://pe-centos6.localdomain:8140")
			.acceptHeader("pson, b64_zlib_yaml, yaml, raw")
			.acceptEncodingHeader("gzip;q=1.0,deflate;q=0.6,identity;q=0.3")
			.connection("close")
			.userAgentHeader("Ruby")


	val headers_3 = Map(
			"Accept" -> """pson, b64_zlib_yaml, yaml, dot, raw""",
			"Content-Type" -> """application/x-www-form-urlencoded"""
	)

	val headers_5 = Map(
			"Content-Type" -> """text/yaml"""
	)


	val scn = scenario("Scenario Name")
		.exec(http("node")
					.get("/production/node/pe-centos5.localdomain")
			)
		.pause(446 milliseconds)
		.exec(http("filemeta plugins")
					.get("/production/file_metadatas/plugins")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
					.queryParam("""ignore""", """--- 
  - ".svn"
  - CVS
  - ".git"""")
			)
		.pause(2)
		.exec(http("catalog")
					.post("/production/catalog/pe-centos5.localdomain")
					.headers(headers_3)
						.param("""facts_format""", """b64_zlib_yaml""")
						.param("""facts""", """eNqlWFdv6zoSfr%2B%2Fguunc%2BDYoqgu4AIbt9hxd%2BwUvxgUSVmy1aLihv3xS1mu%0ASe7BApsgiTXfN9RwOI2pVCrgX3Fm7YXQWjGSmqMsilhqmoOQMtNsYZImfwEQ%0AYJ%2BZIGIVwoI0TJSqFxLs0dDHbsDhDfYylpiAfwQAx8RxU75WFnMdV9LVQpwt%0AGU42LE7cMDBBSazCKiwdoTWLA%2BaZoOcG2e4osfj6a8o2LmELm8JF4h74WiUZ%0AGmrpG8Gh5EJAhmyoCpL177SE4jMNibIm65Iq6%2FBn3oYFNIw587W%2FxTF7%2BJnl%0Acx95FxJ4deM0wx54%2BcbmrinxbTxwSx%2B4YoEX3jPBvSsB8DHBlMYsybUgNGHd%0ARIZZR6aBTO2x0A0TG%2FuutzfBhNE2TgthxGKcusEy2Scp801Q54c1fDliXmJR%0AN0ldeie1%2BfGy%2BPZMtKpYvMF2PVask5vBdil64L%2BkBzcJDVU9uc3%2BpMEfwgIA%0AB8c0942bYB4K6ikUztKT%2F67yMEm%2FRtoRyM2Ow7DYphtwm7nlR6%2By1IEPXviQ%0AuOnJJjc6eW%2BRY%2FmmDFQVVb2KZP5XOm3v6uQz7R88HbDUx8n6zEKKUj3%2FnF7o%0Ap9nlVQr8ZoUX5gDS8nA%2FO%2Fe86BE7LnVNhny5QkeVJfUqy3eYSy8xe3nFP%2B2x%0ASCsfr64HjKrqLRYzj%2BckK4CqqFeQJlelqlhlnnLLu1uA80q3MUX4KRan1nID%0A7N1ClCUkdqO00C0CD5xeCpSqBn4dVX7frXc1ijMuCN%2FGF%2FACXWUmCWNWkauw%0A4mIJXZ%2BCMC9K5jLGkeOS5Mq4k5xYUcwjjGfRlXUnKVinFOefqY%2BDLE8kXu7y%0AitHh4emBehhHYZ6NYXBDjeKQZuQU4yVZhrV30GDJOg0jnsg2i1lAGBh5OLXD%0A2L9RTFjsYi%2FIfCt%2FxyAMWIG5YXKtVSMnZIG7A1NGnCD0wqXLEtCbNkq33PNB%0AqtVzqB6Bkw8XFKe5aVAVIBIQFC%2FpcrfHU1UEnYBUC8L9zr4UxPsN3e%2FlxK0o%0AKpApEA3ANKBbwFAB0gCiFdUGlgiIAgwNUAsQBAwEtFMJzbK8MpQUVW6IRlOr%0A6DVD5TGMGhW1VRMrdcXQGrU6MtA5m9N9xO0bpg6Li33xGhTvT11BgaiqS6Bf%0AK91gdsxyTNLUqmJcsGSLo3Mv4Y4ETzfyk8Y3ec5f%2BFYOQVmrGsa9yi2ESl%2Bs%0AK8DCwK%2FWFVhh4C2Whin2vm%2FrVHt%2BrmUc3Ibx%2BqfS%2BYVxV9ZO2JcGxFP2W7p%2B%0AofyQ6xFOHf4sZEks8OrDgyRMhMTinfJedJEce84No3g%2BPhbCC3LlHD%2FkHSX%2F%0AdHqvwz3NNXkk89aShDEJsyDNN3mJ8EIOz0n%2Ba%2FI7z3P2a9r%2FDVwF1EczUHz1%0AgYIgAP8GqCrDp%2FbhywpfV84reJSACrNPguMMds1VqcqPAfwqRjPQzPsfL0m8%0AhEq57ytRzIcMtpUqSK8sVYlJvJKcSmo%2B2fHGwajLU00Io1Qo1hY81xKOY1%2BO%0ALo6fxKpRFS9at0OBUZXOqevlIxoXpnHG7mQLFvAUJ4z%2BCEah55KbNZF4j5Ms%0A5rUvPU5UJiiW4kFyzwkD213%2BL5TibSZIcbxkfPN3nEL%2FHkocmuA14yqlR%2F5V%0AkwYHXBfXROrzp3rt8Tmq695K7iMcuRPdWGfz7DVt4lAVZuVZ53XV0dLtqj9W%0A2k539T6bDR%2F5IPNG3%2BBeXQ%2BJNC%2BX2%2BUXQ30P7dglrUl7aimyknkfn62DIESx%0A2ugbPX8rfQym8WtMmq2G8r6cuOXPcV1Nu%2Btyx%2FWb1nttBZ2PnSWpg56z1Ncb%0AofMsBBZJ7aEuDC3vHdkf72J3k9vfGjeMPobBSOmMnssDbCSUqvrnkjWMobTl%0AhE6t5SXi8r3dhH1v%2BVTvMrvnbZ0onbUmQ9fZffrxdiv7y7ijRsZ%2BQF5Wq8d%2B%0AvJlls30wXs8nj71mqwdf%2FcH6bTZs9gRhbBudaa%2FVJV7qlXejl%2BWAKc%2BG6O%2Ft%0Ajt0dD5pK8BGTep0IwSYavXrJe3MzyRpkjl7jckQNNJ%2B%2FruKG%2Fega9eZ4P%2F5w%0A6vOJnLqO6tOjvY%2FPZJparwdL7yTv9Gm29z5f5sJO2r8P0Ww4X87x2zgQp74n%0At13feG4aiIwjzcqeQtbLxIBt0mnjDR%2F09PCiZ4bQ3NdH4242Gh9e3N7rU9lT%0AdnIsjINo%2BDTe1MRuT2k66xHTVl6yWe%2FWqfH27D5Dsau%2BSdqhscyCblmEn8Hr%0ARJ7G5RF7Et9qQdRK6ItFVuO%2F%2Fy6do8qOFjSffP9T%2BasoDC8v7dYIICACy1BU%0AKtsWEaGMCJVU3UIKNgzZpqLNVNHCNtKhRL4oIiCJmqbYimVYsmZjSzdsJIsW%0AUg1bIxKEUMGSSglVFZuokqJhpKnU5hWBSYZEqUjOtsU%2FRPyeoObxsZN7fdx8%0A9Ox5J5kPd%2FNQRE%2Fzj33n2Z%2B1R6oRMduZy%2F3sGcEWq29Suv7wrKa8TMuCEjpj%0ANE0P40HrrTeuZ01%2F5701cJ3swnrTaylRa9rZQJlH0WpSFtTko1GeTcSpRSPn%0A2efX0I7ymRmbx7gtrext2ZVmewH2t%2B1PfelsnpLZgJLJvE6bNRtjUXiyVX2j%0A9A6k2V0%2Fs%2FLs0Et2KH0UpK4Pu%2BOp15h5QnnwstxOW%2F66ITa8eELtSbuuB63a%0AbpqsRwf78ErHQzvy3OE7hc1ApwIfKtjYhaHebqB9o7cbaKvepvu0fXt8mnc%2F%0AZs1Do6G%2BMbx8W31sYG1bf3f8ntPFnb5sNXu7NW64m60w13s4tDafwzAJnFFr%0AZUy1ie60SX30sr2PkPiHCBHzbwszTTGIxv8qGEqyJCJoiVyMbFvWeYhjbKhE%0A%2BqKIeGhp0DAYpKqkSVhTGcTUlhXuL5kp1LJUZhtUwrolKjLVKbIIhZqkGlIe%0Ae5qCi0nJ9dmBz5kmGDWmxbAVuJ8ZywcurBOoSzYqxFFOzfuECRG%2FwmVxUroB%0A%2BES5P15k74RH2rUDnqQJ4wWcJsdp5nyD3xQzpAk2fj4nFjcfPsiexTfNhisT%0AnC4sPlAU%2FW6D42PPy5sdv1GeWl9BKzSyJA39Bc5S59g78ms69hJ2vmCpKbb4%0ANXhx2wylqnKG%2F4RGbHHbwC8zErc9H0FvzOZMPimF8S3%2FirjBHQIvCJ%2BTiPMD%0AwlvPkt8KF5TZOPPSG4Z%2Bvn4Wjlhw9%2FzBT8UkwEckflj5%2BQqXC3jx%2F6Jk74PS%0AIj%2B3JMV%2BVDoOr6JUgWpF5AVOMiXZlCGoQO180SCey3s8YXH6x%2F8ZFLT%2Ff%2Fph%0Au8gtbmAmuLVMNmFuWRVJCk%2BT3EATwv8C6nnGKg%3D%3D%0A""")
			)
		.pause(607 milliseconds)
		.exec(http("filemeta mco plugins")
					.get("/production/file_metadatas/modules/pe_mcollective/plugins")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
			)
		.pause(1)
		.exec(http("report")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_5)
						.fileBody("PE3VanillaCent5_request_5.txt")
			)

    // This is kind of a dirty hack.  Here's the deal.
    // In order to simulate real world agent runs, we need to sleep 30 minutes
    // in between each series of agent requests.  That can be achieved
    // easily by adding a "pause" to the end of the run.
    // However, if we do that, then after the final series of requests, we'll sleep
    // for 30 minutes before the simulation can end, even though that is entirely
    // unnecessary.  Since most of our jenkins jobs are going to run 2-6 sims,
    // that would mean we're sleeping for 1-3 extra hours and uselessly tying up the
    // hardware.  Thus, we need to make the sleep conditional based on whether
    // or not we're on the final repetition.

    // Here we've replaced our "pause" with a Gatling "session function",
    // which basically just sets a session variable to check to see if
    // we are on the final repetition, and if not, sleep for 30 mins.
    .exec((session: Session) => {
    val repetitionCount = session.getAttributeAsOption[Int](REPETITION_COUNTER).getOrElse(0) + 1
        println("Agent " + session.userId +
            " completed " + repetitionCount + " repetitions.")
        session.setAttribute(REPETITION_COUNTER, repetitionCount)
    }).doIf((session) => session.getTypedAttribute[Int](REPETITION_COUNTER) < totalNumReps) {
        exec((session) => {
          println("This is not the last repetition; sleeping.")
          session
        }).pause(30 minutes)
    }.doIf((session) => session.getTypedAttribute[Int](REPETITION_COUNTER) >= totalNumReps) {
      exec((session) => {
        println("That was the last repetition.  Not sleeping.")
        session
      })
    }

	setUp(scn.users(1).protocolConfig(httpConf))
}
