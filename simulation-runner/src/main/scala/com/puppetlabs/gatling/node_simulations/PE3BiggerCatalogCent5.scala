package com.puppetlabs.gatling.node_simulations

import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._
import com.puppetlabs.gatling.runner.SimulationWithScenario

class PE3BiggerCatalogCent5 extends SimulationWithScenario {

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
		.pause(561 milliseconds)
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
						.param("""facts""", """eNqlWFdv6zoSfr%2B%2Fguunc%2BDYoqgu4AIbt9hxd%2BwUvxgUSVmy1aLihv3xS1mu%0ASe7BApsgiTXfN9RwOI2pVCrgX3Fm7YXQWjGSmqMsilhqmoOQMtNsYZImfwEQ%0AYJ%2BZIGIVwoI0TJSqFxLs0dDHbsDhDfYylpiAfwQAx8RxU75WFnMdV9LVQpwt%0AGU42LE7cMDBBSazCKiwdoTWLA%2BaZoOcG2e4osfj6a8o2LmELm8JF4h74WiUZ%0AGmrpG8Gh5EJAhmyoCpL177SE4jMNibIm65Iq6%2FBn3oYFNIw587W%2FxTF7%2BJnl%0Acx95FxJ4deM0wx54%2BcbmrinxbTxwSx%2B4YoEX3jPBvSsB8DHBlMYsybUgNGHd%0ARIZZR6aBTO2x0A0TG%2FuutzfBhNE2TgthxGKcusEy2Scp801Q54c1fDliXmJR%0AN0ldeie1%2BfGy%2BPZMtKpYvMF2PVask5vBdil64L%2BkBzcJDVU9uc3%2BpMEfwgIA%0AB8c0942bYB4K6ikUztKT%2F67yMEm%2FRtoRyM2Ow7DYphtwm7nlR6%2By1IEPXviQ%0AuOnJJjc6eW%2BRY%2FmmDFQVVb2KZP5XOm3v6uQz7R88HbDUx8n6zEKKUj3%2FnF7o%0Ap9nlVQr8ZoUX5gDS8nA%2FO%2Fe86BE7LnVNhny5QkeVJfUqy3eYSy8xe3nFP%2B2x%0ASCsfr64HjKrqLRYzj%2BckK4CqqFeQJlelqlhlnnLLu1uA80q3MUX4KRan1nID%0A7N1ClCUkdqO00C0CD5xeCpSqBn4dVX7frXc1ijMuCN%2FGF%2FACXWUmCWNWkauw%0A4mIJXZ%2BCMC9K5jLGkeOS5Mq4k5xYUcwjjGfRlXUnKVinFOefqY%2BDLE8kXu7y%0AitHh4emBehhHYZ6NYXBDjeKQZuQU4yVZhrV30GDJOg0jnsg2i1lAGBh5OLXD%0A2L9RTFjsYi%2FIfCt%2FxyAMWIG5YXKtVSMnZIG7A1NGnCD0wqXLEtCbNkq33PNB%0AqtVzqB6Bkw8XFKe5aVAVIBIQFC%2FpcrfHU1UEnYBUC8L9zr4UxPsN3e%2FlxK0o%0AKpApEA3ANKBbwFAB0gCiFdUGlgiIAgwNUAsQBAwEtFMJzbK8MpQUVW6IRlOr%0A6DVD5TGMGhW1VRMrdcXQGrU6MtA5m9N9xO0bpg6Li33xGhTvT11BgaiqS6Bf%0AK91gdsxyTFKkKtQvWLLF0bmXcEeCpxv5SeObPOcvfCuHoKxVDeNe5RZCpS%2FW%0AFWBh4FfrCqww8BZLwxR737d1qj0%2F1zIObsN4%2FVPp%2FMK4K2sn7EsD4in7LV2%2F%0AUH7I9QinDn8WsiQWePXhQRImQmLxTnkvukiOPeeGUTwfHwvhBblyjh%2FyjpJ%2F%0AOr3X4Z7mmjySeWtJwpiEWZDmm7xEeCGH5yT%2FNfmd5zn7Ne3%2FBq4C6qMZKL76%0AQEEQgH8DVJXhU%2FvwZYWvK%2BcVPEpAhdknwXEGu%2BaqVOXHAH4Voxlo5v2PlyRe%0AQqXc95Uo5kMG20oVpFeWqsQkXklOJTWf7HjjYNTlqSaEUSoUawueawnHsS9H%0AF8dPYtWoihet26HAqErn1PXyEY0L0zhjd7IFC3iKE0Z%2FBKPQc8nNmki8x0kW%0A89qXHicqExRL8SC554SB7S7%2FF0rxNhOkOF4yvvk7TqF%2FDyUOTfCacZXSI%2F%2Bq%0ASYMDrotrIvX5U732%2BBzVdW8l9xGO3IlurLN59po2cagKs%2FKs87rqaOl21R8r%0Abae7ep%2FNho98kHmjb3CvrodEmpfL7fKLob6HduyS1qQ9tRRZybyPz9ZBEKJY%0AbfSNnr%2BVPgbT%2BDUmzVZDeV9O3PLnuK6m3XW54%2FpN6722gs7HzpLUQc9Z6uuN%0A0HkWAouk9lAXhpb3juyPd7G7ye1vjRtGH8NgpHRGz%2BUBNhJKVf1zyRrGUNpy%0AQqfW8hJx%2Bd5uwr63fKp3md3ztk6UzlqToevsPv14u5X9ZdxRI2M%2FIC%2Br1WM%2F%0A3syy2T4Yr%2BeTx16z1YOv%2FmD9Nhs2e4Iwto3OtNfqEi%2F1yrvRy3LAlGdD9Pd2%0Ax%2B6OB00l%2BIhJvU6EYBONXr3kvbmZZA0yR69xOaIGms9fV3HDfnSNenO8H384%0A9flETl1H9enR3sdnMk2t14Old5J3%2BjTbe58vc2En7d%2BHaDacL%2Bf4bRyIU9%2BT%0A265vPDcNRMaRZmVPIetlYsA26bTxhg96enjRM0No7uujcTcbjQ8vbu%2F1qewp%0AOzkWxkE0fBpvamK3pzSd9YhpKy%2FZrHfr1Hh7dp%2Bh2FXfJO3QWGZBtyzCz%2BB1%0AIk%2Fj8og9iW%2B1IGol9MUiq%2FHff5fOUWVHC5pPvv%2Bp%2FFUUhpeXdmsEEBCBZSgq%0AlW2LiFBGhEqqbiEFG4ZsU9FmqmhhG%2BlQIl8UEZBETVNsxTIsWbOxpRs2kkUL%0AqYatEQlCqGBJpYSqik1USdEw0lRq84rAJEOiVCRn2%2BIfIn5PUPP42Mm9Pm4%2B%0Aeva8k8yHu3kooqf5x77z7M%2FaI9WImO3M5X72jGCL1TcpXX94VlNepmVBCZ0x%0AmqaH8aD11hvXs6a%2F894auE52Yb3ptZSoNe1soMyjaDUpC2ry0SjPJuLUopHz%0A7PNraEf5zIzNY9yWVva27EqzvQD72%2FanvnQ2T8lsQMlkXqfNmo2xKDzZqr5R%0AegfS7K6fWXl26CU7lD4KUteH3fHUa8w8oTx4WW6nLX%2FdEBtePKH2pF3Xg1Zt%0AN03Wo4N9eKXjoR157vCdwmagU4EPFWzswlBvN9C%2B0dsNtFVv033avj0%2Bzbsf%0As%2Bah0VDfGF6%2BrT42sLatvzt%2Bz%2BniTl%2B2mr3dGjfczVaY6z0cWpvPYZgEzqi1%0AMqbaRHfapD562d5HSPxDhIj5t4WZphhE438VDCVZEhG0RC5Gti3rPMQxNlQi%0AfVFEPLQ0aBgMUlXSJKypDGJqywr3l8wUalkqsw0qYd0SFZnqFFmEQk1SDSmP%0APU3BxaTk%2BuzA50wTjBrTYtgK3M%2BM5QMX1gnUJRsV4iin5jVdMqHI73BZnJRu%0AED5S7o832TvhkXZUuhMnjJdwmgM6MuBpZtgUY6QJNn4%2BKhaXHz7LnsU3%2FYZr%0AE5wuLD5TFC1vg%2BNj28v7Hb9UnrpfQSs0siQN%2FQXOUufYPvKbOvYSdr5jqSm2%0A%2BE14cdsPpapyhv%2BERmxx28MvYxK3PZ9Cb8zmTD4shfEt%2F4q4wR0CLwgflYjz%0AA8K7z5JfDBeU2Tjz0huGfr6BFo5YcPf8wU%2FFMMCnJH5c%2BRELlzt48S%2BjZO%2BD%0A0iI%2FuCTFflQ6zq%2BiVIFqRZSAKJqSZCoaqEDtfNcgnsvbPGFx%2Bsd%2FGxS0%2F38A%0AYrvILS5hJri1DJkwt6wqyrw6Hg00IfwvdujGuA%3D%3D%0A""")
			)
		.pause(2)
		.exec(http("filemeta mco plugins")
					.get("/production/file_metadatas/modules/pe_mcollective/plugins")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
			)
		.pause(5)
		.exec(http("report")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_5)
						.fileBody("PE3BiggerCatalogCent5_request_5.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
