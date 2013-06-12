package com.puppetlabs.gatling.node_simulations 
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._

class BiggerCatalogCent5 extends com.puppetlabs.gatling.runner.SimulationWithScenario {

	val httpConf = httpConfig
			.baseURL("https://pe-centos6.localdomain:8140")
			.acceptHeader("pson, yaml, b64_zlib_yaml, raw")
			.connection("close")


	val headers_2 = Map(
			"Accept" -> """pson, dot, b64_zlib_yaml, yaml, raw""",
			"Content-Type" -> """application/x-www-form-urlencoded"""
	)

	val headers_18 = Map(
			"Accept" -> """b64_zlib_yaml, yaml, raw""",
			"Content-Type" -> """text/yaml"""
	)


	val scn = scenario("Scenario Name")
		.exec(http("plugins")
					.get("/production/file_metadatas/plugins")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
					.queryParam("""ignore""", """--- 
  - ".svn"
  - CVS
  - ".git"""")
			)
		.pause(52)
		.exec(http("catalog")
					.post("/production/catalog/pe-centos5.localdomain")
					.headers(headers_2)
						.param("""facts_format""", """b64_zlib_yaml""")
						.param("""facts""", """eNqVV1mP6rgSfr%2B%2FwrefzhEDWUhCiDTS7Wbfl2ZrXpCTOMSQDTth%2B%2FVjJ4EG%0Apmek26ilxFVll2v56kuxWAT%2FJYl5EUJzh6zYGCdRhGLDGIY2MowmtGL6HwCO%0A0EsQNQB7BCAioZ1YcQB9ZIC3xeAECQILTOIEemDswdgJif%2BWqgYo9iHdMzVZ%0AVUu3fzETmiEktg%2BDxGGnJAQRptYJYuSBWkiikMAYh0GmyjU2mG6i1Du2ZZxq%0AO9CjKNPIJEdEKDPi55UqJVkCv7L7gAbbl0QEUwTkkl6SfmdWONJiaHqIbr4t%0ApVK5pGZiijwcJOcNCtiVLGQzaUwSdL%2FbKST7DYpdkZtV5JKklSS5crvfs9Nw%0Ai4L4aYNUTuPQjzbstlymSZpUzoQkDOONG%2FIQC%2Fw5u6R7odiCHsuAhShlPoVJ%0Auqn07JIX8jXuCf9lMivhR21gErsbKwyc5%2FAlAT4kCPMbSiK0dLHi5HGFscsW%0AhYQSYY%2BIiUhIBWriwHheuq94IXPwQSN7T1%2BzxbvkWyd94LfkT8%2BhtxJCWOA2%0APq9HkCUCB9tUx4%2BTDcVxGn1Fz%2B%2FpUdPGNLaYflahTRxAL882tG3CAvccoDx4%0APrRu4jylomiINUOuGrJiqDWjUskVkR8SlogrL39VZPVUBoOP103%2B2Z7FLECe%0AD3eP1aq9XJtlCG9%2FvLVzsJlJhIoWi0tI1VIaYTv0IQ6%2B%2B%2Bq5SRVF%2FFiBOqL7%0AOIzAFDmIBdVCL90aoQ3zKiQPzSC%2F3Vr%2Bx4LLg83rpsa8GX3e9mFlY7mPTXUL%0Az1O3Z9jxB%2BgEVimvUg%2Bzff7fNs4QjF588LaJsY9oDP3ojZk3CQbdJABiBYiK%0AoVQNRQNFsSKKQBZvnZaGiyKCoRckvskdG4YBesSvW0H8AGL0BCOHIJT6yvZt%0A5YWQRNyRjQ0vaSXkcMPAAD1hADfPK%2BnJ%2FFYHUehh6%2FIQjzyQfPMr89IA4%2Fos%0AAwwWAtYMyMbsAkIYxUKGO4KHTSGLD5Nu0ieppD86SRErN5v7qclSXqQRf40o%0AKCLn7aV5%2Fg54kqw%2FtkYej7Ks89zdWuNeQ%2BIN539Nf3OoR79mg98AV4plVRYH%0AoDaeg%2F%2Bx9FbFVvuaR4O6NoV7dGGW7%2Bzvozy8wpq0t8oD9lb7eO9GNd3bKQMZ%0ARniqV%2FfJOlnEDRhqwrww7yx2nUp82g0matvt7Vbz%2Beg9pPHSXooXbT%2ByyutC%0AoV34rGqr0CHYak7bM1NV1MT7OjSvghARrT6o9v1T%2BWs4IwtiNZp1dbWd4sJh%0AUtPi3r7QwX7DXH3sRPfrbJa1Yd%2Fd6vuj0OkKgWnFzkgXRqa3kp2vldQ7cv%2Bb%0Ak3p1AMVgrHbG3cIQVqlta%2Fphi%2BrVUfnEFDofTY9K21W7IQ68bavWQ07fO7lR%0APG9OR9g9H3xyOin%2BlnS0qHoZWp%2B73fuAHOfJ%2FBJM9uvpe7%2FR7IsLf7hfzkeN%0AviBMnGpn1m%2F2LC%2F2Cufx53aI1G5V8i9Ox%2BlNhg01%2BCJWrWYJwTEaLzy6ahyn%0ASd1aywtSiOyqvF4vdqTuvONqrTG5TL7c2nqqxNjVfDv1971rzWJzcTX1Dl3Z%0ArfnFO3yuhXP5shrJ89F6u4bLSSDNfE9pY7%2FabVRlaxJVzKQVon4iBegYz%2BpL%0AeNXj66eeVIXGpTae9JLx5PqJ%2B4tWwVPPChEmQTRqTY4fUq%2BvNtz9GFV2Hj3u%0Az%2Fu4uuzirij1tGW5cq1vk6BXkMRDsJgqM1IYo5a0%2FAiiJrU%2FTWs3%2BfPPvIcu%0AvBlHsYvII5jZiFoER3HWcBmsAYI8BBnqqKUK%2BJVOlN8%2FDXnWRzT00PNsxRy0%0AmB4nUG%2B8ef7wwj%2F43MrEkFgu68wUFA2Ay7r26E1%2BMJ80pcoddBlMvwifYSOb%0AGzEkW8QQ4e4oIo80h%2FVuvmMYIc62gi29MGblv4K5j4OnoaA%2FzrFvH2S%2Bo16U%0AKwpjUFIJeblTMNkyjW9zNnHFnzmSBZ8jd8xIpQGOPh8Uma%2FUgT72GBRMkd2G%0AGTHiA%2BjOklDA7MLAT%2FlWPgfZya%2Bci6bReJik2t8maR7OJ8TmpOOGgKqYX8Nl%0AeJKN2u%2B5%2FBAjA%2FT5Pg9EdXNkQydFavaQojWHaWacie%2BI%2FpgvvfRzun4okdvc%0ASnlOOq0eiGAYWDDemMzkXzwQMrXb2Lpn4nF2Pc3MfJgXVQ0oNqhYQDKBLAP2%0AqinAkosVEagiKCtAVAFk41sBqgVulMhl0eDWvG7ZIVjLmyCjAxbi7PhfGE8W%0A5Sc6xSrxPjvID7PjYsmN9LXD8WvSePecdYeuR%2Bd1KMmt9del0%2FXn7bFWjZDj%0ArpVB0pXFJqodY3v%2F5ZkNZRsXBDV0J%2FIsvk6GzWV%2FUksa%2Ftlb1mHNOoe1htdU%0Ao%2BascxQVhse7aUHQ6Fe9MJ9KM9OO3K7Pvrg66iGpHt9Ju7xzTgVcnl8EcXBq%0AH%2FSte2zR%2BdC2puua3fhwIJSElqPpR7V%2FtRq9fRcV5tc%2BPcvxu1Du%2BWJvMvPq%0Ac08oDD%2B3p1nT39elukemtjNt1%2FSg%2BXGe0f346lwX9mTkRB4erWyxEei2kGAb%0ATbAY6u26fKn3z8PKrn%2FstU7L99a69zVvXOt1bYngdrn7Ooofp9rK9ftuD3YG%0Aitnon%2Fewjo8nYa33YWgeD6OQBu64uavOKlPdbVu18efphrU503DDhNBvOsiw%0A5TFp%2Bo2KZ6k1wGueGSr%2Fy9dadgZfM5QySI96ri5M4UNtZVwlDuO0rF94%2FAsP%0Az2jYC6LeGdE%2FkSGGFNmHhqaUtTt2f7erYTHyU1RKYhHDsvz9FoR8JhhbAiMX%0AW%2FRb42kl12JsOOBY8K31tJJp8cNf8emli9A5wtknt5GS46KoFTltVg2J02aG%0A2ZKuqpw9G6L4F%2Bc8BGY%3D%0A""")
			)
		.pause(5)
		.exec(http("aespe security")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/aespe_security.rb")
			)
		.pause(128 milliseconds)
		.exec(http("ssh key")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/sshkey.rb")
			)
		.pause(169 milliseconds)
		.exec(http("app package")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/package.rb")
			)
		.pause(131 milliseconds)
		.exec(http("app service")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/service.rb")
			)
		.pause(119 milliseconds)
		.exec(http("registration meta")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/registration/meta.rb")
			)
		.pause(165 milliseconds)
		.exec(http("app puppetd")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/puppetd.rb")
			)
		.pause(192 milliseconds)
		.exec(http("agent puppetd")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.ddl")
			)
		.pause(128 milliseconds)
		.exec(http("agent package")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.ddl")
			)
		.pause(122 milliseconds)
		.exec(http("agent puppetral")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.rb")
			)
		.pause(164 milliseconds)
		.exec(http("agent puppetd")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.rb")
			)
		.pause(123 milliseconds)
		.exec(http("agent service")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.ddl")
			)
		.pause(119 milliseconds)
		.exec(http("agent puppetral")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.ddl")
			)
		.pause(197 milliseconds)
		.exec(http("agent service")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.rb")
			)
		.pause(119 milliseconds)
		.exec(http("agent package")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.rb")
			)
		.pause(1)
		.exec(http("action policy")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/util/actionpolicy.rb")
			)
		.pause(1)
		.exec(http("report")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_18)
						.fileBody("BiggerCatalogCent5_request_18.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
