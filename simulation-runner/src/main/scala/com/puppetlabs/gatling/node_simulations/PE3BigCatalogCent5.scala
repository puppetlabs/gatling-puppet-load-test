package com.puppetlabs.gatling.node_simulations 
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._
import com.puppetlabs.gatling.runner.SimulationWithScenario

class PE3BigCatalogCent5 extends SimulationWithScenario {

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
		.exec(http("request_1")
					.get("/production/node/pe-centos5.localdomain")
			)
		.pause(564 milliseconds)
		.exec(http("request_2")
					.get("/production/file_metadatas/plugins")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
					.queryParam("""ignore""", """--- 
  - ".svn"
  - CVS
  - ".git"""")
			)
		.pause(3)
		.exec(http("request_3")
					.post("/production/catalog/pe-centos5.localdomain")
					.headers(headers_3)
						.param("""facts_format""", """b64_zlib_yaml""")
						.param("""facts""", """eNqlWFlz6joSfr%2B%2FQsPTOUXAtry76lZN2AJhJ5CFF0qWZGzwFtlmq%2FnxI2PW%0AJPfUVE1SSXB%2FX8utVm9KpVIB%2F2KZvRcie0Vxao2yOKapZQ0iQi2rhXCa%2FAVA%0AiAJqgZhWMA3TKFGrfoSRT6IAeSGHN8jPaGIB%2FhEAxLDrpXytjHEdTza0Qpwt%0AKUo2lCVeFFqgJFXFqlg6QmvKQupboOeF2e4osfn6a0I3HqYLh4iLxDvwtUqK%0AaGqlbwSX4AsBmoqpqVAxvtMSgs40KCm6YsiaYog%2F8zY0JBHjzNf%2BFjH68DMr%0A4D7yLyTw6rE0Qz54%2BcbmrinxbTxwSx%2B4YoEX3rPAvSsBCBBGhDCa5FqiaIl1%0AC5pWHVomtPTHQjdKHBR4%2Ft4CE0raKC2EMWUo9cJlsk9SGligzg9r%2BHLE%2FMQm%0AXpJ65E7q8OOl7PZM9KpUvMHxfFqsk5tBdyl84L%2FkBy%2BJTE07uc35JOEfwgIA%0AFzGS%2B8ZLEA8F7RQKZ%2BnJf1d5lKRfI%2B0I5GazKCq26YXcZm750as0dcUHP3pI%0AvPRkkxefvLfIsXxTJqxKmlGFCv8rn7Z3dfKZ9g%2BeDmkaoGR9ZkFVrZ5%2FTi8M%0A0uzyKlX8ZoUf5QDU83A%2FO%2Fe86BE7LnVNhny5QkdTZO0qy3eYSy8xe3nFP%2B2x%0ASKsAra4HDKvaLcaoz3OSFkBVMipQV6pyVapSX73l3S3AeaXbmML8FItTa3kh%0A8m8hQhPMvDgtdIvAA6eXArWqg19Hld93612N4owLwrfxBbxAV5mFI0YrSlWs%0AeEiG16cwyouStWQodj2cXBl3khMrZjzCeBZdWXeSgnVKcf6ZBCjM8kTi5S6v%0AGB0enj6oRyyO8myMwhtqzCKS4VOMlxRFrL2DBk3WaRTzRHYooyGmYOSj1IlY%0AcKOYUOYhP8wCO3%2FHIAppgXlRcq1VIzeiobcDU4rdMPKjpUcT0Js2Srfc80Fq%0A1XOoHoGTDxcEpblpoiaIUICidEmXuz2eqiLohLhaEO539qUg3m%2Fofi8nbkXV%0AgEKAZAKqA8MGpgagDiCpaA6wJYBVYOqA2ABDYEKgn0poluWVoaRqSkMym3rF%0AqJkaj2HYqGitmlSpq6beqNWhCc%2FZnO5jbt8wdSkr9sVrENufuoIqwqohg36t%0AdIM5jOaYrEpVQ79gyRbF517CHQmebuQnjW%2FynL8I7BwSFb1qmvcqtxAsfbGu%0AAAsDv1pXYIWBt1gapcj%2Fvq1T7fm5lnFwG7H1T6XzC%2BOurJ2wLw2Ip%2By3dP1C%0A%2BSHXY5S6%2FFnIEibw6sODJEqExOad8l50kRx7zg2jeD4%2BFsILcuUcP%2BQdJf90%0Aeq%2FLPc01eSTz1pJEDEdZmOabvER4IRfPSf5r8jvPc%2Fpr2v8NPBXURzNQfPWB%0ACkUA%2Fg1gVRGf2ocvK3xdOa%2FgcQIq1DkJjjPYNVflKj8G8KsYzUAz73%2B8JPES%0AKue%2Br8SMDxl0K1egUVlqMpV5JTmV1Hyy442DEo%2BnmhDFqVCsLfieLRzHvhxd%0AHD9JVbMqXbRuhwKzKp9T189HNC5MWUbvZAsa8hTHlPwIxpHv4Zs1oXSP44zx%0A2pceJyoLFEvxILnnRKHjLf8XSvE2C6SILSnf%2FB2n0L%2BHEpckaE25SumRf9Xk%0AwQHVpTWW%2B%2FypXnt8juuGv1L6EMXexDDX2Tx7TZso0oRZedZ5XXX0dLvqj9W2%0A2129z2bDRz7IvJE3ca%2Bth1iel8vt8oupvUcO83Br0p7aqqJm%2Fsdn6yAIMdMa%0AfbMXbOWPwZS9MtxsNdT35cQrf47rWtpdlzte0LTfayvR%2FdjZsjbouUtjvRE6%0Az0Jo49QZGsLQ9t%2Bh8%2FEudTe5%2Fa1xw%2BwjMRypndFzeYDMhBDN%2BFzShjmUt5zQ%0AqbX8RFq%2Bt5ti318%2B1bvU6flbN05nrcnQc3efAdtulWDJOlps7gf4ZbV67LPN%0ALJvtw%2FF6PnnsNVs98TUYrN9mw2ZPEMaO2Zn2Wl3sp355N3pZDqj6bErB3uk4%0A3fGgqYYfDNfrWAg38ejVT96bm0nWwHP4ysoxMeF8%2FrpiDefRM%2BvN8X784dbn%0AEyX1XC0gR3sfn%2FE0tV8PttFJ3snTbO9%2FvsyFnbx%2FH8LZcL6co7dxKE0DX2l7%0AgfncNCEex7qdPUW0l0kh3aTTxhs6GOnhxchMobmvj8bdbDQ%2BvHi916eyr%2B4U%0AJozDePg03tSkbk9tuusR1Vd%2Bslnv1qn59uw9i1JXe5P1Q2OZhd2yJH6GrxNl%0Aysoj%2BiS91cK4lZAXG6%2FGf%2F9dOkeVEy9IPvn%2Bp%2FJXURheXtqtEYBAArapakRx%0AbCyJCsRE1gwbqsg0FYdIDtUkGznQEGX8RRECWdJ11VFt01Z0B9mG6UBFsqFm%0AOjqWRVFUkawRTDTVwZqs6gjqGnF4RaCyKRMi4bNt7IeI32PYPD52cq%2BPm4%2B%2B%0AM%2B8k8%2BFuHknwaf6x7zwHs%2FZIM2PquHOlnz1DsUXrm5SsP3y7qSzTsqBG7hhO%0A08N40HrrjetZM9j5bw1Ux7uo3vRbatyadjaiwqNoNSkLWvLRKM8m0tQmsfsc%0A8GtoR%2F3MzM0ja8srZ1v25NleEPvb9qexdDdPyWxA8GReJ82ag5AkPDmasVF7%0AB9zsrp9peXboJTuYPgpyNxC746nfmPlCefCy3E5bwbohNXw2Ic6kXTfCVm03%0ATdajg3N4JeOhE%2Fve8J2IzdAgAh8q6NgTI6PdgPtGbzfQV71N92n79vg0737M%0AmodGQ3ujaPm2%2BtiItW393Q16bhd1%2Bord7O3WqOFttsLc6KHI3nwOoyR0R62V%0AOdUnhtvG9dHL9j5C2A8RIuXfNqK6amKd%2F1WRKCuyBEVb4mLoOIrBQxwhU8Py%0AF0XIQ0sXTZOKRJN1GekaFRFxFJX7S6EqsW2NOiaRkWFLqkIMAm1MRF3WTDmP%0APV1FxaTkBfTA50wLjBrTYtgKvc%2BM5gMXMrBoyA4sxHFOzWs6tFSZ3%2BEylpRu%0AED5S7o832TvhkXZUuhMnlJdwkgMGVM73mE0xRlpgE%2BSjYnH54bPsWXzTb7g2%0ARunC5jNF0fI2iB3bXt7v%2BKXy1P0KWqGRJWkULFCWusf2kd%2FUkZ%2FQ8x1LS5HN%0Ab8KL234oV9Uz%2FCc0povbHn4Zk7jt%2BRR6YzZn8mEpYrf8K%2BKFd4h4QfiohN0f%0AEN59lvxiuCDUQZmf3jCM8w20cMSCu%2BcPfiqGAT4l8ePKj1i43MGLfxkl%2BwCU%0AFvnBJSkK4tJxfpXkiqhVJBlIkgU1S5RBRdTPdw3se7zNY8rSP%2F7boKD9%2FwMQ%0A3cVecQmzwL1lam5ZVYKqYhq5gZYo%2FhflG8a6%0A""")
			)
		.pause(1)
		.exec(http("request_4")
					.get("/production/file_metadatas/modules/pe_mcollective/plugins")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
			)
		.pause(1)
		.exec(http("request_5")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_5)
						.fileBody("PE3BigCatalogCent5_request_5.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
