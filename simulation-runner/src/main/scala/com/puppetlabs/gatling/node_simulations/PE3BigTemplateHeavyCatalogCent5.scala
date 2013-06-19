package com.puppetlabs.gatling.node_simulations 
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._
import com.puppetlabs.gatling.runner.SimulationWithScenario

class PE3BigTemplateHeavyCatalogCent5 extends SimulationWithScenario {

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
		.pause(451 milliseconds)
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
		.pause(5)
		.exec(http("catalog")
					.post("/production/catalog/pe-centos5.localdomain")
					.headers(headers_3)
						.param("""facts_format""", """b64_zlib_yaml""")
						.param("""facts""", """eNqlWFlz6joSfr%2B%2FQsPTOUXAtry76lZN2AJhJ5CFF0qWZGzwFtlmq%2FnxI2PW%0AJPfUVE1SSXB%2FX8utVm9KpVIB%2F2KZvRcie0Vxao2yOKapZQ0iQi2rhXCa%2FAVA%0AiAJqgZhWMA3TKFGrfoSRT6IAeSGHN8jPaGIB%2FhEAxLDrpXytjHEdTza0Qpwt%0AKUo2lCVeFFqgJFXFqlg6QmvKQupboOeF2e4osfn6a0I3HqYLh4iLxDvwtUqK%0AaGqlbwSX4AsBmoqpqVAxvtMSgs40KCm6YsiaYog%2F8zY0JBHjzNf%2BFjH68DMr%0A4D7yLyTw6rE0Qz54%2BcbmrinxbTxwSx%2B4YoEX3rPAvSsBCBBGhDCa5FqiaIl1%0AC5pWHVomtPTHQjdKHBR4%2Ft4CE0raKC2EMWUo9cJlsk9SGligzg9r%2BHLE%2FMQm%0AXpJ65E7q8OOl7PZM9KpUvMHxfFqsk5tBdyl84L%2FkBy%2BJTE07uc35JOEfwgIA%0AFzGS%2B8ZLEA8F7RQKZ%2BnJf1d5lKRfI%2B0I5GazKCq26YXcZm750as0dcUHP3pI%0AvPRkkxefvLfIsXxTJqxKmlGFCv8rn7Z3dfKZ9g%2BeDmkaoGR9ZkFVrZ5%2FTi8M%0A0uzyKlX8ZoUf5QDU83A%2FO%2Fe86BE7LnVNhny5QkdTZO0qy3eYSy8xe3nFP%2B2x%0ASKsAra4HDKvaLcaoz3OSFkBVMipQV6pyVapSX73l3S3AeaXbmML8FItTa3kh%0A8m8hQhPMvDgtdIvAA6eXArWqg19Hld93612N4owLwrfxBbxAV5mFI0YrSlWs%0AeEiG16cwyouStWQodj2cXBl3khMrZjzCeBZdWXeSgnVKcf6ZBCjM8kTi5S6v%0AGB0enj6oRyyO8myMwhtqzCKS4VOMlxRFrL2DBk3WaRTzRHYooyGmYOSj1IlY%0AcKOYUOYhP8wCO3%2FHIAppgXlRcq1VIzeiobcDU4rdMPKjpUcT0Js2Srfc80Fq%0A1XOoHoGTDxcEpblpoiaIUICidEmXuz2eqiLohLhaEO539qUg3m%2Fofi8nbkXV%0AgEKAZAKqA8MGpgagDiCpaA6wJYBVYOqA2ABDYEKgn0poluWVoaRqSkMym3rF%0AqJkaj2HYqGitmlSpq6beqNWhCc%2FZnO5jbt8wdSkr9sVrENufuoIqwqohg36t%0AdIM5jOaYrPEENS9YskXxuZdwR4KnG%2FlJ45s85y8CO4dERa%2Ba5r3KLQRLX6wr%0AwMLAr9YVWGHgLZZGKfK%2Fb%2BtUe36uZRzcRmz9U%2Bn8wrgrayfsSwPiKfstXb9Q%0Afsj1GKUufxayhAm8%2BvAgiRIhsXmnvBddJMeec8Mono%2BPhfCCXDnHD3lHyT%2Bd%0A3utyT3NNHsm8tSQRw1EWpvkmLxFeyMVzkv%2Ba%2FM7znP6a9n8DTwX10QwUX32g%0AQhGAfwNYVcSn9uHLCl9Xzit4nIAKdU6C4wx2zVW5yo8B%2FCpGM9DM%2Bx8vSbyE%0AyrnvKzHjQwbdyhVoVJaaTGVeSU4lNZ%2FseOOgxOOpJkRxKhRrC75nC8exL0cX%0Ax09S1axKF63bocCsyufU9fMRjQtTltE72YKGPMUxJT%2BCceR7%2BGZNKN3jOGO8%0A9qXHicoCxVI8SO45Ueh4y%2F%2BFUrzNAiliS8o3f8cp9O%2BhxCUJWlOuUnrkXzV5%0AcEB1aY3lPn%2Bq1x6f47rhr5Q%2BRLE3Mcx1Ns9e0yaKNGFWnnVeVx093a76Y7Xt%0Adlfvs9nwkQ8yb%2BRN3GvrIZbn5XK7%2FGJq75HDPNyatKe2qqiZ%2F%2FHZOghCzLRG%0A3%2BwFW%2FljMGWvDDdbDfV9OfHKn%2BO6lnbX5Y4XNO332kp0P3a2rA167tJYb4TO%0AsxDaOHWGhjC0%2FXfofLxL3U1uf2vcMPtIDEdqZ%2FRcHiAzIUQzPpe0YQ7lLSd0%0Aai0%2FkZbv7abY95dP9S51ev7WjdNZazL03N1nwLZbJViyjhab%2BwF%2BWa0e%2B2wz%0Ay2b7cLyeTx57zVZPfA0G67fZsNkThLFjdqa9Vhf7qV%2FejV6WA6o%2Bm1KwdzpO%0AdzxoquEHw%2FU6FsJNPHr1k%2FfmZpI18By%2BsnJMTDifv65Yw3n0zHpzvB9%2FuPX5%0AREk9VwvI0d7HZzxN7deDbXSSd%2FI02%2FufL3NhJ%2B%2Ffh3A2nC%2Fn6G0cStPAV9pe%0AYD43TYjHsW5nTxHtZVJIN%2Bm08YYORnp4MTJTaO7ro3E3G40PL17v9ansqzuF%0ACeMwHj6NNzWp21Ob7npE9ZWfbNa7dWq%2BPXvPotTV3mT90FhmYbcsiZ%2Fh60SZ%0AsvKIPklvtTBuJeTFxqvx33%2BXzlHlxAuST77%2FqfxVFIaXl3ZrBCCQgG2qGlEc%0AG0uiAjGRNcOGKjJNxSGSQzXJRg40RBl%2FUYRAlnRddVTbtBXdQbZhOlCRbKiZ%0Ajo5lURRVJGsEE011sCarOoK6RhxeEahsyoRI%2BGwb%2ByHi9xg2j4%2Bd3Ovj5qPv%0AzDvJfLibRxJ8mn%2FsO8%2FBrD3SzJg67lzpZ89QbNH6JiXrD99uKsu0LKiRO4bT%0A9DAetN5643rWDHb%2BWwPV8S6qN%2F2WGremnY2o8ChaTcqClnw0yrOJNLVJ7D4H%0A%2FBraUT8zc%2FPI2vLK2ZY9ebYXxP62%2FWks3c1TMhsQPJnXSbPmICQJT45mbNTe%0AATe762danh16yQ6mj4LcDcTueOo3Zr5QHrwst9NWsG5IDZ9NiDNp142wVdtN%0Ak%2FXo4BxeyXjoxL43fCdiMzSIwIcKOvbEyGg34L7R2w30VW%2FTfdq%2BPT7Nux%2Bz%0A5qHR0N4oWr6tPjZibVt%2Fd4Oe20WdvmI3e7s1anibrTA3eiiyN5%2FDKAndUWtl%0ATvWJ4bZxffSyvY8Q9kOESPm3jaiumljnf1UkyoosQdGWuBg6jmLwEEfI1LD8%0ARRHy0NJF06Qi0WRdRrpGRUQcReX%2BUqhKbFujjklkZNiSqhCDQBsTUZc1U85j%0AT1dRMSl5AT3wOdMCo8a0GLZC7zOj%2BcCFDCwasgMLcZxT85ouW7LE73AZS0o3%0ACB8p98eb7J3wSDsq3YkTyks4yQFD0cXTzLApxkgLbIJ8VCwuP3yWPYtv%2Bg3X%0Axihd2HymKFreBrFj28v7Hb9UnrpfQSs0siSNggXKUvfYPvKbOvITer5jaSmy%0A%2BU14cdsP5ap6hv%2BExnRx28MvYxK3PZ9Cb8zmTD4sReyWf0W88A4RLwgflbD7%0AA8K7z5JfDBeEOijz0xuGcb6BFo5YcPf8wU%2FFMMCnJH5c%2BRELlzt48S%2BjZB%2BA%0A0iI%2FuCRFQVw6zq%2BSXBG1iiQDCVqibKk6qIj6%2Ba6BfY%2B3eUxZ%2Bsd%2FGxS0%2F38A%0AorvYKy5hFri3TM4tq0qKKSlabqAliv8FZtTGuA%3D%3D%0A""")
			)
		.pause(4)
		.exec(http("filemeta mco plugins")
					.get("/production/file_metadatas/modules/pe_mcollective/plugins")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
			)
		.pause(2)
		.exec(http("report")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_5)
						.fileBody("PE3BigTemplateHeavyCatalogCent5_request_5.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
