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
		.pause(664 milliseconds)
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
		.pause(7)
		.exec(http("request_3")
					.post("/production/catalog/pe-centos5.localdomain")
					.headers(headers_3)
						.param("""facts_format""", """b64_zlib_yaml""")
						.param("""facts""", """eNqlWFdv6zoSfr%2B%2Fguunc%2BDYkqhKARfYuMWOu2On%2BMWgSMqSrRYVN%2ByPX8py%0ATXIPFtgESaz5vqGGw2lMpVIB%2F4ozay%2BE1oqR1BxlUcRS0xyElJlmC5M0%2BQuA%0AAPvMBBGrEBakYaJWvZBgj4Y%2BdgMOb7CXscQE%2FCMAOCaOm%2FK1spjruLKhFeJs%0AyXCyYXHihoEJSlJVrIqlI7RmccA8E%2FTcINsdJRZff03ZxiVsYVNxkbgHvlZJ%0AEZFW%2BkZwKLkQIFKQpkLF%2BE5LKD7ToKToiiFriiH%2BzNuwgIYxZ772tzhmDz%2Bz%0AfO4j70ICr26cZtgDL9%2FY3DUlvo0HbukDVyzwwnsmuHclAD4mmNKYJbmWKJpi%0A3YTIrEMTQVN%2FLHTDxMa%2B6%2B1NMGG0jdNCGLEYp26wTPZJynwT1PlhDV%2BOmJdY%0A1E1Sl95JbX68LL49E70qFW%2BwXY8V6%2BRmsF0KH%2Fgv%2BcFNQqRpJ7fZnzT4Q1gA%0A4OCY5r5xE8xDQTuFwll68t9VHibp10g7ArnZcRgW23QDbjO3%2FOhVljrigxc%2B%0AJG56ssmNTt5b5Fi%2BKQSrkmZUocL%2FyqftXZ18pv2DpwOW%2BjhZn1lQVavnn9ML%0A%2FTS7vEoVv1nhhTkA9Tzcz849L3rEjktdkyFfrtDRFFm7yvId5tJLzF5e8U97%0ALNLKx6vrAcOqdovFzOM5yQqgKhkVqCtVuSpVmafe8u4W4LzSbUwRforFqbXc%0AAHu3EGUJid0oLXSLwAOnlwK1qoNfR5Xfd%2BtdjeKMC8K38QW8QFeZScKYVZSq%0AWHGxDK9PQZgXJXMZ48hxSXJl3ElOrCjmEcaz6Mq6kxSsU4rzz9THQZYnEi93%0AecXo8PD0QD2MozDPxjC4oUZxSDNyivGSooi1d9BgyToNI57INotZQBgYeTi1%0Aw9i%2FUUxY7GIvyHwrf8cgDFiBuWFyrVUjJ2SBuwNTRpwg9MKlyxLQmzZKt9zz%0AQWrVc6gegZMPFxSnuWmiJohQgKJ0SZe7PZ6qIugEpFoQ7nf2pSDeb%2Bh%2BLydu%0ARdWAQoGEANOBYQGkAagDSCuaDSwJEBUgHVALEAgQBPqphGZZXhlKqqY0JNTU%0AK0YNaTyGYaOitWpSpa4ivVGrQwTP2ZzuI27fMHVYXOyL16B4f%2BoKqgirhgz6%0AtdINZscsx2RVv8WSLY7OvYQ7EjzdyE8a3%2BQ5f%2BFbOSQqehWhe5VbCJa%2BWFeA%0AhYFfrSuwwsBbLA1T7H3f1qn2%2FFzLOLgN4%2FVPpfML466snbAvDYin7Ld0%2FUL5%0AIdcjnDr8WciSWODVhwdJmAiJxTvlvegiOfacG0bxfHwshBfkyjl%2ByDtK%2Fun0%0AXod7mmvySOatJQljEmZBmm%2FyEuGFXDwn%2Ba%2FJ7zzP2a9p%2FzdwVVAfzUDx1Qcq%0AFAH4N4BVRXxqH76s8HXlvIJHCagw%2ByQ4zmDXXJWr%2FBjAr2I0A828%2F%2FGSxEuo%0AnPu%2BEsV8yGBbuQKNylKTmcwryamk5pMdbxyMujzVhDBKhWJtwXMt4Tj25eji%0A%2BEmqoqp00bodClBVPqeul49oXJjGGbuTLVjAU5ww%2BiMYhZ5LbtaE0j1OspjX%0AvvQ4UZmgWIoHyT0nDGx3%2Bb9QireZIMXxkvHN33EK%2FXsocWiC14yrlB75V00e%0AHHBdWhO5z5%2FqtcfnqG54K6UPceRODLTO5tlr2sShJszKs87rqqOn21V%2FrLad%0A7up9Nhs%2B8kHmjb6Je209JPK8XG6XX5D2HtqxS1qT9tRSFTXzPj5bB0GIYq3R%0ARz1%2FK38MpvFrTJqthvq%2BnLjlz3FdS7vrcsf1m9Z7bSU6HztL1gY9Z2msN0Ln%0AWQgsktpDQxha3ju0P96l7ia3vzVuoD4Wg5HaGT2XBxgllGrG55I10FDeckKn%0A1vISafnebop9b%2FlU7zK7522dKJ21JkPX2X368Xar%2BMu4o0VoPyAvq9VjP97M%0Astk%2BGK%2Fnk8des9UTX%2F3B%2Bm02bPYEYWyjzrTX6hIv9cq70ctywNRnJPl7u2N3%0Ax4OmGnzEpF4nQrCJRq9e8t7cTLIGmcPXuBxRBOfz11XcsB9dVG%2BO9%2BMPpz6f%0AKKnraD492vv4TKap9XqwjE7yTp9me%2B%2FzZS7s5P37EM6G8%2BUcv40Daep7Stv1%0A0XMTQTKOdCt7ClkvkwK2SaeNN3ww0sOLkSGhua%2BPxt1sND68uL3Xp7Kn7pRY%0AGAfR8Gm8qUndntp01iOmr7xks96tU%2FT27D6LUld7k%2FVDY5kF3bIkfgavE2Ua%0Al0fsSXqrBVEroS8WWY3%2F%2Frt0jio7WtB88v1P5a%2BiMLy8tFsjAIEELKRqVLEt%0AIokKJFTWDAuqGCHFppLNNMnCNjREmXxRhECWdF21VQtZim5jy0A2VCQLasjW%0AiSyKoopljRKqqTbReFPAUNeozSsCk5FMqUTOtsU%2FRPyewObxsZN7fdx89Ox5%0AJ5kPd%2FNQgk%2Fzj33n2Z%2B1RxqKmO3MlX72DMUWq29Suv7wrKayTMuCGjpjOE0P%0A40HrrTeuZ01%2F5701cJ3swnrTa6lRa9rZiAqPotWkLGjJR6M8m0hTi0bOs8%2Bv%0AoR31M0Obx7gtr%2Bxt2ZVne0Hsb9ufxtLZPCWzASWTeZ02azbGkvBka8ZG7R1I%0As7t%2BZuXZoZfsYPooyF1f7I6nXmPmCeXBy3I7bfnrhtTw4gm1J%2B26EbRqu2my%0AHh3swysdD%2B3Ic4fvVGwGBhX4UMHGrhga7QbcN3q7gb7qbbpP27fHp3n3Y9Y8%0ANBraG8PLt9XHRqxt6%2B%2BO33O6uNNXrGZvt8YNd7MV5kYPh9bmcxgmgTNqrdBU%0AnxhOm9RHL9v7CIl%2FiBAp%2F7Yw01VEdP5XxaKsyBIULYmLoW0rBg9xjJFG5C%2BK%0AkIeWLiLERKrJuox1jYmY2orK%2FaUwlVqWxmxEZWxYkqpQg0KLUFGXNSTnsaer%0AuJiUXJ8d%2BJxpglFjWgxbgfuZsXzgwgYRDdmGhTjKqflEaSoyv8JlcVK6AfhE%0AuT9eZO%2BER1qucydNGC%2FgNJfzgeN8i9kUQ6QJNn4%2BKBZXHz7JnsU33YZrE5wu%0ALD5RFA1vg%2BNj08u7Hb9SnnpfQSs0siQN%2FQXOUufYPPJ7OvYSdr5haSm2%2BD14%0AcdsN5ap6hv%2BERmxx28EvQxK3PZ9Bb8zmTD4qhfEt%2F4q4wR0iXhA%2BKBHnB4T3%0AniW%2FFi4os3HmpTcM43z%2FLByx4O75g5%2BKUYDPSPy08gMWLjfw4h9Gyd4HpUV%2B%0AcEmK%2Fah0nF4luSJqFYlXOGRKminKoCLq55sG8Vze5AmL0z%2F%2B06Cg%2Ff%2FjD9tF%0AbnEFM8G9ZUpuWVVCEioMNEXxvx%2FnxmE%3D%0A""")
			)
		.pause(4)
		.exec(http("request_4")
					.get("/production/file_metadatas/modules/pe_mcollective/plugins")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
			)
		.pause(2)
		.exec(http("request_5")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_5)
						.fileBody("PE3BigCatalog_request_5.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
