package com.puppetlabs.gatling.node_simulations

import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._
import com.puppetlabs.gatling.runner.SimulationWithScenario

class PE3BiggerTemplateHeavyCatalogCent5 extends SimulationWithScenario {

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
		.pause(602 milliseconds)
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
		.pause(31)
		.exec(http("request_3")
					.post("/production/catalog/pe-centos5.localdomain")
					.headers(headers_3)
						.param("""facts_format""", """b64_zlib_yaml""")
						.param("""facts""", """eNqlWFlz6joSfr%2B%2FQsPTOUXAtry76lZN2AJhJ5CFF0qWZGzwFtlmq%2FnxI2PW%0AJPfUVE1SSXB%2FX8utVm9KpVIB%2F2KZvRcie0Vxao2yOKapZQ0iQi2rhXCa%2FAVA%0AiAJqgZhWMA3TKFGrfoSRT6IAeSGHN8jPaGIB%2FhEAxLDrpXytjHEdTza0Qpwt%0AKUo2lCVeFFqgJFXFqlg6QmvKQupboOeF2e4osfn6a0I3HqYLh4iLxDvwtUqK%0AaGqlbwSX4AsBmoqpqVAxvtMSgs40KCm6YsiaYog%2F8zY0JBHjzNf%2BFjH68DMr%0A4D7yLyTw6rE0Qz54%2BcbmrinxbTxwSx%2B4YoEX3rPAvSsBCBBGhDCa5FqiaIl1%0AC5pWHVomtPTHQjdKHBR4%2Ft4CE0raKC2EMWUo9cJlsk9SGligzg9r%2BHLE%2FMQm%0AXpJ65E7q8OOl7PZM9KpUvMHxfFqsk5tBdyl84L%2FkBy%2BJTE07uc35JOEfwgIA%0AFzGS%2B8ZLEA8F7RQKZ%2BnJf1d5lKRfI%2B0I5GazKCq26YXcZm750as0dcUHP3pI%0AvPRkkxefvLfIsXxTJqxKmlGFCv8rn7Z3dfKZ9g%2BeDmkaoGR9ZkFVrZ5%2FTi8M%0A0uzyKlX8ZoUf5QDU83A%2FO%2Fe86BE7LnVNhny5QkdTZO0qy3eYSy8xe3nFP%2B2x%0ASKsAra4HDKvaLcaoz3OSFkBVMipQV6pyVapSX73l3S3AeaXbmML8FItTa3kh%0A8m8hQhPMvDgtdIvAA6eXArWqg19Hld93612N4owLwrfxBbxAV5mFI0YrSlWs%0AeEiG16cwyouStWQodj2cXBl3khMrZjzCeBZdWXeSgnVKcf6ZBCjM8kTi5S6v%0AGB0enj6oRyyO8myMwhtqzCKS4VOMlxRFrL2DBk3WaRTzRHYooyGmYOSj1IlY%0AcKOYUOYhP8wCO3%2FHIAppgXlRcq1VIzeiobcDU4rdMPKjpUcT0Js2Srfc80Fq%0A1XOoHoGTDxcEpblpoiaIUICidEmXuz2eqiLohLhaEO539qUg3m%2Fofi8nbkXV%0AgEKAZAKqA8MGpgagDiCpaA6wJYBVYOqA2ABDYEKgn0poluWVoaRqSkMym3rF%0AqJkaj2HYqGitmlSpq6beqNWhCc%2FZnO5jbt8wdSkr9sVrENufuoIqwqohg36t%0AdIM5jOaYrMrcYRcs2aL43Ety%2BdON%2FKTxTZ7zF4GdQ6KiV03zXuUWgqUv1hVg%0AYeBX6wqsMPAWS6MU%2Bd%2B3dao9P9cyDm4jtv6pdH5h3JW1E%2FalAfGU%2FZauXyg%2F%0A5HqMUpc%2FC1nCBF59eJBEiZDYvFPeiy6SY8%2B5YRTPx8dCeEGunOOHvKPkn07v%0AdbmnuSaPZN5akojhKAvTfJOXCC%2Fk4jnJf01%2B53lOf037v4GngvpoBoqvPlCh%0ACMC%2FAawq4lP78GWFryvnFTxOQIU6J8FxBrvmqlzlxwB%2BFaMZaOb9j5ckXkLl%0A3PeVmPEhg27lCjQqS02mMq8kp5KaT3a8cVDi8VQTojgVirUF37OF49iXo4vj%0AJ6lqVqWL1u1QYFblc%2Br6%2BYjGhSnL6J1sQUOe4piSH8E48j18syaU7nGcMV77%0A0uNEZYFiKR4k95wodLzl%2F0Ip3maBFLEl5Zu%2F4xT691DikgStKVcpPfKvmjw4%0AoLq0xnKfP9Vrj89x3fBXSh%2Bi2JsY5jqbZ69pE0WaMCvPOq%2Brjp5uV%2F2x2na7%0Aq%2FfZbPjIB5k38ibutfUQy%2FNyuV1%2BMbX3yGEebk3aU1tV1Mz%2F%2BGwdBCFmWqNv%0A9oKt%2FDGYsleGm62G%2Br6ceOXPcV1Lu%2Btyxwua9nttJbofO1vWBj13aaw3QudZ%0ACG2cOkNDGNr%2BO3Q%2B3qXuJre%2FNW6YfSSGI7Uzei4PkJkQohmfS9owh%2FKWEzq1%0Alp9Iy%2Fd2U%2Bz7y6d6lzo9f%2BvG6aw1GXru7jNg260SLFlHi839AL%2BsVo99tpll%0As304Xs8nj71mqye%2BBoP122zY7AnC2DE7016ri%2F3UL%2B9GL8sBVZ9NKdg7Hac7%0AHjTV8IPheh0L4SYevfrJe3MzyRp4Dl9ZOSYmnM9fV6zhPHpmvTnejz%2Fc%2Bnyi%0ApJ6rBeRo7%2BMznqb268E2Osk7eZrt%2Fc%2BXubCT9%2B9DOBvOl3P0Ng6laeArbS8w%0An5smxONYt7OniPYyKaSbdNp4QwcjPbwYmSk09%2FXRuJuNxocXr%2Ff6VPbVncKE%0AcRgPn8abmtTtqU13PaL6yk826906Nd%2BevWdR6mpvsn5oLLOwW5bEz%2FB1okxZ%0AeUSfpLdaGLcS8mLj1fjvv0vnqHLiBckn3%2F9U%2FioKw8tLuzUCEEjANlWNKI6N%0AJVGBmMiaYUMVmabiEMmhmmQjBxqijL8oQiBLuq46qm3aiu4g2zAdqEg21ExH%0Ax7IoiiqSNYKJpjpYk1UdQV0jDq8IVDZlQiR8to39EPF7DJvHx07u9XHz0Xfm%0AnWQ%2B3M0jCT7NP%2Fad52DWHmlmTB13rvSzZyi2aH2TkvWHbzeVZVoW1Mgdw2l6%0AGA9ab71xPWsGO%2F%2Btgep4F9WbfkuNW9PORlR4FK0mZUFLPhrl2USa2iR2nwN%2B%0ADe2on5m5eWRteeVsy5482wtif9v%2BNJbu5imZDQiezOukWXMQkoQnRzM2au%2BA%0Am931My3PDr1kB9NHQe4GYnc89RszXygPXpbbaStYN6SGzybEmbTrRtiq7abJ%0AenRwDq9kPHRi3xu%2BE7EZGkTgQwUde2JktBtw3%2BjtBvqqt%2Bk%2Bbd8en%2Bbdj1nz%0A0GhobxQt31YfG7G2rb%2B7Qc%2Ftok5fsZu93Ro1vM1WmBs9FNmbz2GUhO6otTKn%0A%2BsRw27g%2BetneRwj7IUKk%2FNtGVFdNrPO%2FKhJlRZagaEtcDB1HMXiII2RqWP6i%0ACHlo6aJpUpFosi4jXaMiIo6icn8pVCW2rVHHJDIybElViEGgjYmoy5op57Gn%0Aq6iYlLyAHvicaYFRY1oMW6H3mdF84EIGFg3ZgYU4zql5TZct2eR3uIwlpRuE%0Aj5T74032TnikHZXuxAnlJZzkgKFK%2BmlC2hRjpAU2QT4qFpcfPsuexTf9hmtj%0AlC5sPlMULW%2BD2LHt5f2OXypP3a%2BgFRpZkkbBAmWpe2wf%2BU0d%2BQk937G0FNn8%0AJry47YdyVT3Df0Jjurjt4ZcxidueT6E3ZnMmH5Yidsu%2FIl54h4gXhI9K2P0B%0A4d1nyS%2BGC0IdlPnpDcM430ALRyy4e%2F7gp2IY4FMSP678iIXLHbz4l1GyD0Bp%0AkR9ckqIgLh3nV0muiFpFkoEELUmyVAlURP08mWLf420eU5b%2B8d8GBe3%2FH4Do%0ALvaKS5gF7i1Tcsuqii6rCswNtETxv%2BSJxqo%3D%0A""")
			)
		.pause(16)
		.exec(http("request_4")
					.get("/production/file_metadatas/modules/pe_mcollective/plugins")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
			)
		.pause(5)
		.exec(http("request_5")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_5)
						.fileBody("PE3BiggerTemplateHeavyCatalogCent5_request_5.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
