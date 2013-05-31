package com.puppetlabs.gatling.node_simulations

import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import akka.util.duration._
import com.puppetlabs.gatling.runner.SimulationWithScenario

class VanillaDebian6LongRunning extends SimulationWithScenario {

	val httpConf = httpConfig
			.baseURL("https://pe-ubuntu-lucid:8140")
			.acceptHeader("pson, b64_zlib_yaml, yaml, raw")
			.connection("close")


	val headers_2 = Map(
			"Accept" -> """pson, b64_zlib_yaml, yaml, dot, raw""",
			"Content-Type" -> """application/x-www-form-urlencoded"""
	)

	val headers_18 = Map(
			"Accept" -> """b64_zlib_yaml, yaml, raw""",
			"Content-Type" -> """text/yaml"""
	)


	val scn = scenario("Vanilla Debian6 Node")
    .exec(http("request_1")
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
		.exec(http("request_2")
					.post("/production/catalog/pe-debian6.local")
					.headers(headers_2)
						.param("""facts_format""", """b64_zlib_yaml""")
						.param("""facts""", """eNqVV1mTqroWfr%2B%2FItenvcsjMggiT9d5nmdfrABBkCEIwYFff8KgrdY%2Bp%2Bp2%0AV9tCwsrKyjcsSqUS%2BG8QqY8yVs9II8os8n1EFGWCdaQoHaiR8D8AXKEToVAB%0A9CsA4Q36oRUjBRQEmWdqNTBuFNIRHx2vKAgt7NExnpEZLruvYhjoLvQig8aL%0AAhTQ4b5HkAOaOPBxAAl9JJtq%2BVDXAxTSxQpcjWc4SWb4Cv0v8NkEGGimRVAa%0ARwGWIEvpbS0KCXaPMCLmUcOeQR83oBOi7CEPEReGdpKVKDLPPzZfMjz6yWZI%0AEOXTr1ZAIugo4OreYIDSe0mRQrqwbtHsy9gnZT8tVdmx1HIycEzLyDFyOt1F%0ALg4eRoCSyBVOYiT%2Bp0wB1ugOccA%2B6%2FBr8TspBfq1Gv8GVrXESywLmrM1%2BB8Q%0AmArb7cXZk8ijqWHPRR5RkjB6pCWly1aE2k%2FpWFZhNYWvKTVJMWoKrBTesiKY%0AJJsriCzPiNVXWgHG5Ghil2ZcTr6nNyOfWC466vCRhs1mOqGqWyHRUagFlk%2By%0A824h1YIe6E7W5ZHlRXcgMSzDg1%2FhJUIoRr8L7%2FFCRA9JT0JWxZqYZ2dcdBrI%0ARyU9DSUxDtago2MXWt9bPCJisv%2B8zzA0gxDa6EGn1OlPQ5jEsMk9NL6dXLbq%0A83ojuV2ft7b6TZ4squX%2BYezP%2BO18BOHdmDgaOjz0eMW72yIS1OL1ur5h1ndZ%0A2KlLjVGLlC%2BaG9cvVXPklfU7vHf4x3o3rRhl4%2Baq9mzea3K1YrMV7wZ7vbzf%0ANMy%2BLg33wiq2DHe5JtLjcLvL95Uw9%2BONNBPtVos7L1v29dyftK9ov1%2FJvWB4%0AI%2FZgcdnp1%2BnE42tscbgSxYnOtdcLadV5SNUmwlWtO5vXoDwRbryBRrK4Gy3x%0AYMIdhtyDZ09Ls21r88uEI%2B2xP982V9tu2LKaZ7Y9Uw0WHlrrQN6vHkIs8CPb%0AvPFNezqfjSf7eF%2BZdmdk4Zry2GjPpZiD9TOSJuv5xCzbh%2BKlr%2For73bhxP5h%0Auwo1z7IQXJ39aqvRXfSNHOc4JCd6WkcdGTByyJs4yEzlAw8mjoIEDTz3Qdij%0Ag3POsslvDhMqIseEtCn%2F6DSSCsob3bGPEk3xTuGDDroKyLD5ST4NRwmLCvmK%0AGcwU8I05GwUeomxJMf2zfqI2PoVxcE0Wp5iNVBouKjmRZunvJLH0j%2BU%2Fk6ck%0ACLGDPrNPpqRx81pxjMRw1Q%2FmaVSdPZgwNWfXU359SDTzrc7cS%2BJemvamc5%2FJ%0AwFMqK2%2FjNJpJb5SjMCindSmHKq3R2%2FXr8mcg%2FZJd0o%2FCyzJyLUwtQ3qJToic%0ApLCfFfBNKrU0%2FD%2BdleZYNNV3q6kyPAd%2BZeYF2lRSAz%2BwQgRSE8qlx08A5oeg%0AhHJ8fjnSZpyI%2FV%2Bg72lM4fukqUslCUicxAm5EUUnBMOfJFiGe0E0A817ghLz%0ANLAEEC95NakxJqtaIVRA5Nkevv0RJ%2FCzQFn8ADk0A%2FSKXxJLkizlFAgN6FrO%0A4wN8OXp%2Bnksl%2Bt0acl%2F%2FcoaXKWd85PhqyseP09BQUqBv8X6S%2BYYD%2B%2FPhvFKJ%0Aab5DXWZypFvJIdIqJG1HIVH7vxz81k3k5peRoFCpsI0d3WloE%2ByDBTJQgDwN%0AgZkDiYEDN98iifIcpIogvVoW1%2FJw8K5NP7Nzl%2BFElv2uxHPoTz1K1lGFDxcU%0Ajom8hQS6foHO7gQWGMMHYAXA8QorKhUOlNgqNXuefeIqO%2FH%2FF9zU8fQ%2FOJ6t%0ACWN61WzUp2Swi7acNZLO8IRH02b5vhTYPdZHjq93ooF%2BacOaye3aJ%2FHQwiNu%0Ab5Y9CV%2FubV4ajA%2BSMbFWs7jS8lVBH089dxlym2GnWy%2F22vEjGGzs0fQCG%2BXi%0ApLddLIqdjt%2BF3fZ0qHHSY7hF7jyYTjf77aLBB4fJYHhYYq0295f3s3524NVr%0ATG7aKV7OSPc2fBhJ%2Fp15c75USU2jW%2BnPQ6TbMuuPb70bljXq3vV6v113YoPw%0AgrkzRfO6ndbc1bLjWkItFMZVsjMOvd2BkCFUJ9SJ7X4Nxnuz5fHj6%2BTQM%2BPi%0AfSkJTsieBr3LfeT1%2BOagAw%2FNsV2GI8lsXOR1MxjVg6FaQfsibkheJI%2F2fG9O%0ALpbVPi%2F2m%2B39Gk0dslh4I8Fr7PRGsVbRV8uh3Gz0rw%2F82K3N6%2BYWCCRq1e1T%0AdgZjY9UWWenM9bFwiBe2VmTnWrFrddjluj9q1d1BLzLN6eDQ8qwtmW2KZxzV%0Alo4Y2NxM1cLBQbsRDrbiCRqcRqpd3N%2FE5kjyL%2Bvz3eny46HuLU7VHW957qy4%0ACTfjZvsQ77rc1EFBv92cBQ0Xs3ZrGTZ8tV83O43afsiy0nbZGLPd3Z2NT9S%2F%0A75ddcSmdcmpjT4PkqFK1yPreKwzS3jdpeinX8xY4m5YJGvX8jJQ%2FUpAzh0DV%0Aoc3AO9srjPxDQ3j%2BoGHOpYQ%2FMfZowFlr9aGZLjVB6meWlL8CUDO2oONFrvom%0A5yVRAhUd8CqoQACrQNeBCIEhlqAODB5ICMgagCqglmTUwLN%2FTCXmM96E5pBv%0ARPq3nUSeRS05EXnanFYNlntKx1dT8kcRfrY9ubj84WXlU%2FeyPYJN5u1fcveU%0A3T8oVR6MPJIXnykxUfBmK%2FQgPpzr1XnQgS%2F7eO%2Fh0u6NahpIe7l3LTtS1PwL%0AfOjMb8S8zAPdfSt7PVRSiSyxYikTTyERT6ZSk0WRTzRUYdm%2FAT%2Buh%2BU%3D%0A""")
			)
		.pause(406 milliseconds)
		.exec(http("request_3")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/aespe_security.rb")
			)
		.pause(159 milliseconds)
		.exec(http("request_4")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/sshkey.rb")
			)
		.pause(136 milliseconds)
		.exec(http("request_5")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/package.rb")
			)
		.pause(142 milliseconds)
		.exec(http("request_6")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/service.rb")
			)
		.pause(151 milliseconds)
		.exec(http("request_7")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/registration/meta.rb")
			)
		.pause(156 milliseconds)
		.exec(http("request_8")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/puppetd.rb")
			)
		.pause(160 milliseconds)
		.exec(http("request_9")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.ddl")
			)
		.pause(139 milliseconds)
		.exec(http("request_10")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.ddl")
			)
		.pause(147 milliseconds)
		.exec(http("request_11")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.rb")
			)
		.pause(138 milliseconds)
		.exec(http("request_12")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.rb")
			)
		.pause(160 milliseconds)
		.exec(http("request_13")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.ddl")
			)
		.pause(143 milliseconds)
		.exec(http("request_14")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.ddl")
			)
		.pause(133 milliseconds)
		.exec(http("request_15")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.rb")
			)
		.pause(133 milliseconds)
		.exec(http("request_16")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.rb")
			)
		.pause(146 milliseconds)
		.exec(http("request_17")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/util/actionpolicy.rb")
			)
		.pause(493 milliseconds)
		.exec(http("request_18")
					.put("/production/report/pe-debian6.local")
					.headers(headers_18)
						.fileBody("VanillaDebian6_request_18.txt")
			)
    .pause(30 minutes)

	setUp(scn.users(1).protocolConfig(httpConf))
}
