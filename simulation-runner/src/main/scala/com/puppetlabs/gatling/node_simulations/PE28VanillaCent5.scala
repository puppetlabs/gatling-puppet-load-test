package com.puppetlabs.gatling.node_simulations 
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._

class PE28VanillaCent5 extends com.puppetlabs.gatling.runner.SimulationWithScenario {

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
					.post("/production/catalog/pe-centos5.localdomain")
					.headers(headers_2)
						.param("""facts""", """eNqVV9mOqzoWfe%2BvoPN0jnITZpIgtdRVhMxzZaq8RAZMIAFM2SbT17cZMtWp%0Ae6WuUklgu7yntdbeVCoV7t84sS48svbQpvokiWNIdX2EHKjrLWBT8i%2BOO4Ig%0AgUTn2CPHWQhgh0DsgyBKQgtinRuhCGZ7AbEcn1AMAwgI1LmSWq2Vsp0Ybo8Q%0AEx9FbFWq1qtivk5g4EfJeRumBjkK8A5S6GRbDgqBz44HyAZB%2FpKt%2B2Qbp3dT%0AnMDbJc%2FelJbDE8Cwomqc4nA1mxMtTpI49qopnC1VagKnCpyscILKAchJCqfa%0AXK3wM4QhwhcXw9SCLGtVTeOG7%2FleBGkIyCENQFWrtz%2BhdAv9EbZuI%2BaAUhUq%0APpClx1vEcmd7%2Bg6D2PNt8jjxslKcirEfUT%2FaPU69rOSncuNpCYnPEuez%2BHkU%0AUz7OCskHvsVn9U13t9mTWK3naYyB42BIWF1LYk2qilpVlGrsr14k9QRi4l9h%0AVi9B4NpFFlwGim1ag8wCSwjNku6CgMDSMwp8R%2BcMGNHxx61sRx%2FTBAQvtUPE%0ABaEfXHRuBp0OoM%2BZ3gaoSLaQ%2Fj78Kurz4leGyxgjJ7FpBMJ0X1GE9zXXhORA%0AUczudyGGkQ25SQCoi3BYQBMjm6UBYRslEU2zka%2BDZMfK%2BUCtUBXvTqSZfOyw%0AlN5xnmXlGeq1qiRyv3JicWbEssXKSBjuUhL8zv%2FrnphjmEL3nmeIn42wAtW%2B%0AuSywjS67M%2Fg1%2B80ZDGa%2F5sPfnF%2BryKokDDljsuD%2Byyw1hHbnegfxCeHDFlJP%0AeK18EVoMqMc2%2BIRg%2FgAxoxQiPLEYE1%2BX7isZP59O5O%2FZa75433mcyR4wQjR9%0Ayu3mOkQuIVfaUj%2BEhIIwLjFP5l7C9ZKIE2VOqOmirKsSVxFqrPSSIMqvUWWA%0AyYJ5AOYVsGAHsyI%2FEJgauzIF07lJc%2F4iSjEKfPupzpL4LBIFOVSBVVK%2Bi0QI%0A7AevBEEXDF1q6JKiq4Z%2BE5k79V79Fe9SGYI9ws%2BCme%2FYgc%2BctyFmAcSwYrMX%0ARNTqd4FkJYogA9MgDeLJYYpoRr5vHhfRvrIyhhikUkMujN%2FhC5Hz658hzvBT%0AiEZIkzuyVOHHAtgoIiiAr5KRR%2Fb%2F0uaR65vRv0l4bnl7ZAqRKSR7yFQylUeW%0AyHw7O5nEKRxS7deZfQ8lmPwYBPhD8ljNvvW%2BfMtjRlNSpx2OZd%2FX6loeMops%0AQLcWO%2FwPTvH5sXtyc8Boiqw9qV4IoiT1L8GZFGeCkKpBjNIiooJgKd22Hkqj%0Ay6j3rNUOJDb2Y5pnPy82V4TCsSbO%2FWr5EQh%2BPxDqRy8ILeqfY%2BORgxwbFamm%0AVOWqWIWBehewJ53OGza3zFXwmzzfekFR4R9ab26U5f8Fk6%2FzBUuj6%2B%2BKMQNG%0A7HqbofsbG%2F%2FUxHs3tBNCUbgFCfWyu17L76f4ZBVIh6RSestfAfqLtdxbyyKe%0AQ8ABsiZXemM%2F7%2FLoCgzxYMtD9ma8v%2FViox7slaEEYn9WbxySTbKkJkAavygv%0Aust9t0ZP%2B%2BFU7Xj9%2FXqxGL8hQlfOSrhoh7Etb8rlTvmjoa2Ri327NevMLVVR%0Ak%2BDzq3Xl%2BRhrzWFjEJ7kz9EcL7Fttprqejfzy19TQ6P9Q7nrh6a1ft8L3ufZ%0AkrXRwNvVD0e%2B2%2BMjy6buuM6PrWAtuZ9rsX9M%2FW9Nm40hEKKJ2p30yiPQII6j%0A1b92sNkYyyd2oPveCoi4W3dMYRjs2kYfuoPg5MV00ZqNfe%2F8FeLTSQl3uKvF%0AjcvI%2Ftjv34b4uEgWl2h62MzeBmZrICzD0WG1GJsDnp%2B6je580OrbAQ3K58nH%0AbgTVXkMML27X7U9Hphp9YtswbD46xpNlQNbmcZY07Y20xOXYaUibzXKPm%2B6b%0A3zDM6WX66RmbmUJ9TwudzN%2B3nj2n1vJq1btk7bQXl%2BDrY8Of5ct6LC3Gm90G%0ArKaROA8DpeOHjZ7ZkOxpXLOSNoKDRIzgkc6bK3Ct0%2BtHPWnw5sWYTPvJZHr9%0A8AfLdjlQzwrmp1E8bk%2BP72J%2FoJreYQJr%2B4AcD%2BcDbax6fk8Q%2B9pKrl2buyTq%0Al0XhK1rOlDkuT2BbXL1HcYs4H5a9n%2F7nP6UnqdpmGpUK1ivgc4xD50XWC7bb%0AjAU59TJWZ1swYkMIisKsOxb0ZFx6JVGC2QBFf2SRxyCZ3%2FnoTDnVU%2BdiwlWg%0Ae%2Bt%2BGgVWAMn2ebiRq4U0uF9O9I%2FtrYjbAZesxRaXskDvokYv6QfCmHoQ5%2F8R%0A%2BV8JTI%2BURAHYdaHmPol6SuyY9fq0q5Y0UbvNFIUdAhnfnWxKlkSx8WN%2F%2FOGD%0A55sm5xL3F9eN7OprX%2FAJeOoKqcanwpGaU%2Bq34OJ%2FShhTYzaz2d7z7h%2FhkWyU%0AfMqr9kdeY4%2BNNGzp7%2BZhpmL4BxW72JKZvXZTJk3Nt8DddMlmfN4gUWpvPi%2Fd%0AXrjoTLRGDF1vowyTniS0oHGkzuEzsExlR8u8irypNKfX6ai1GkyNxAzPwaoJ%0ADPuMDDNoqXFr3j0KClOG%2FazMa%2BSzWV7MxLnlxF4vZB%2BvXfUraRzfcEfeu6ey%0ALy8uvDA8db7qO%2B%2FYJouRY882hmO%2BuwCIfNvV6kd1cLXN%2FqEHy4vrgJwl%2BsbL%0A%2FVDoT%2BdBcxHw5dHH7jRvhYem2AzwzHFnHaMetd7Pc3KYXN3r0pmO3Tjwx2tH%0AMKO6wye%2BA6e%2BgOqdpnRpDs6j2n5w7LdPq7f2pv%2B5MK%2FNpraCYLfafx6F95Ox%0A9sKB1wfdoWKZg%2FMBNP3jid%2FUBwBZx68xIpE3ae0b89qs7nVsY%2FJxurE%2B%2Fehj%0A33IZsBhu5AI33%2FpcPrm%2BfFB%2FJ%2Be3%2BsNz7OfTgp7N1RVBq%2BQTt5JO3FVRllhD%0ATAdvXRD%2BBzg3BJU%3D%0A""")
						.param("""facts_format""", """b64_zlib_yaml""")
			)
		.pause(505 milliseconds)
		.exec(http("request_3")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/aespe_security.rb")
			)
		.pause(125 milliseconds)
		.exec(http("request_4")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/sshkey.rb")
			)
		.pause(120 milliseconds)
		.exec(http("request_5")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/package.rb")
			)
		.pause(150 milliseconds)
		.exec(http("request_6")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/service.rb")
			)
		.pause(121 milliseconds)
		.exec(http("request_7")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/registration/meta.rb")
			)
		.pause(120 milliseconds)
		.exec(http("request_8")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/puppetd.rb")
			)
		.pause(126 milliseconds)
		.exec(http("request_9")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.ddl")
			)
		.pause(119 milliseconds)
		.exec(http("request_10")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.ddl")
			)
		.pause(116 milliseconds)
		.exec(http("request_11")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.rb")
			)
		.pause(126 milliseconds)
		.exec(http("request_12")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.rb")
			)
		.pause(132 milliseconds)
		.exec(http("request_13")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.ddl")
			)
		.pause(120 milliseconds)
		.exec(http("request_14")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.ddl")
			)
		.pause(119 milliseconds)
		.exec(http("request_15")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.rb")
			)
		.pause(120 milliseconds)
		.exec(http("request_16")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.rb")
			)
		.pause(123 milliseconds)
		.exec(http("request_17")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/util/actionpolicy.rb")
			)
		.pause(673 milliseconds)
		.exec(http("request_18")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_18)
						.fileBody("PE28VanillaCent5_request_18.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
