package com.puppetlabs.gatling.node_simulations 
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._

class PE28BiggerCatalogCent5 extends com.puppetlabs.gatling.runner.SimulationWithScenario {

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
						.param("""facts""", """eNqVV1mP4rwSfb%2B%2FwpenGTGQhSRApE%2B6zb5vzda8IJM4xJCtbYft13%2FOQhOY%0AnpFut7qV2E65qnzqnHKhUAD%2FJeHuKvi7AzKYPgmDADFdH%2Fkm0vUWNBj9DwAn%0A6ISI6oA%2FAkARwdDxQneHiA5yy%2BEZElRQNaCYoGwAaQdkGfBXTQGGXCiLQBVB%0ASQGiCiACsgJUA5TLudgUDjQGdw6i2xMiFPsetycVS0U1mXahAU2TIMq3zomi%0ALtZ1uarLiq7W9buJIHZ4e4LExNwdgT8IfsAEB%2B%2BEABWS6XilxYPZUua7wTbw%0ACeMmNUmTSqkZ4ht8H58YfuhFc1IyHuUm61ulmO7rUwu62LnqYIbMDmSpw14Y%0AbROSTGp%2Bga5nFJOvIDFszFC8Qge4VNHSPKRxbhGzxWijslyUtKIkl%2FlfJfnW%0AcDDymIEi13lkBn%2FxqVp0fAM6pu9C7CXLwijGLQyZvTV8z%2BLWLOhQlBhx6I4g%0AB0HKt8%2Fphs9PTimKBQxL8uPN8yM%2F9T2BgY0N%2BljxNJKuCgj2GPb2j1VPI8mq%0ANGcBIjCaoVfKkPtwRL1n9YiIh5xHwuUiT0IaP6U2ofCIeMpzb%2FynVhrdYF26%0AGnIzfu2e%2Bf9p882xNl26GV82viS3Nx%2FXbs9ddCZaNUCWvVGGYU8WW6h%2BYubx%0Aw9k1lT3LC6pvT%2BU5u01HrdVgWg%2Bb7sVZNWDduPj1ptNSg9a8exKV42Z2mOUF%0AjX408ouZNN%2BZgd1zee101c%2BwenojndLBOudxaXEVxOG581nZ26c2XYxMY7ap%0Am82aBaEktC2tclIHN6PZP%2FZQfnEb0IvM3oRS3xX707nTWDhCfvS%2BP89b7rEh%0ANRwyM61Zp17xWrXLnB4nN%2Bu2NKdjK3DweG2KTa9iCiE20RSLfqXTkK%2BNwWVU%0APgxO%2FfZ59dbe9D8WzVujoa0Q3K8OHyexdq6vbXdg92F3qOyag8sRNvDpLGwq%0AA%2BjvTp9jn3r2pHWozsuzit0x6pP38z%2F%2FJKfgIeZCeozORlWL9z8x9ygxTLdJ%0A1fF1LK6DDP4C%2B0oxB%2Byf6s1l4ZZiFteAUhG%2F9jz75Lh1%2FGiY14QY%2FSZztk%2BZ%0AB12UrYkMlHQwwF54ybp%2Br7Fv%2FOdemaGR2kvLFywxYSF0wMSBzPKJ%2ByAG7ihK%0AWCdinCTomHhiRo1mt%2FETp4178ZmYMhNRg%2BCAJRCvc5%2FH7yAtBsBLAfxoYQ86%0AP1PYIyeKgHOWg40MF8lS7pk7%2FkAbCb3TqwtyW4ZdRBl0gxxfPLdD0As9IJU4%0AN%2BtSVecPBbEsikAW77QYnWWUCkbC%2BwGirYs9n2QYu%2FKEjOSU4qQ%2BTslFrk%2Bu%0AzGfQicpdlIuVEhjWkkl2jfYYMxuRJLW%2Bz7a2H52BED3Hg2EQOc%2BHQ0IfcOFE%0AgwhHXSROuehcfzn%2Brwg%2Fae7OMLAIQjGT8MDate9wylmS%2Bg56BmoCnwdFJUxU%0AkMsK1yepiJxUo2wuPBFMMIWc0LWU0LlJA7Ltjn%2F7F1kSkmUvEvCE8jTONHqK%0A%2BBdmFKsqK%2BnUjhOs%2BazJI99DGcnI0mm5KEvgR6LyoBllj7M1hx0%2FkKL0grhI%0APfB%2B60atAEAex77BuTuLZGzqIMHvV%2FHeBUwVxS%2FABJAZdlbiv2ayrlXuwSLv%0AhInvuSgihrQk%2BaKM3P%2B%2FEQVRygIKCsjKZf03eGhJsccVl43%2BN9DDwxPo5RSA%0APANfGD0lTKGDkxtBIoHap%2Bn9Va95cmxuTwgpETjo%2BAH6VKA77OnPQ18jsYHM%0AiuQ9fk0Gv2Yea%2BKHyM%2Fo6Vsx%2Fu0gExhqSkl7Stk3op0Ud1pnpVK1WJa%2Bavu5%0A0uA%2BPtNMZrlVntkXw8%2BVFeHPydQW7wPMb%2FqAo1Ea8rd67a0X1CvOQRnKMMCz%0ASvUYbsIla0JfExb5RXd56JbZ%2BTCcqh27f1gvFuM3LiErcyVetePYKG3y%2BU7%2B%0AvaqtfYtgozXrzHeqoobOx2frJggB0RrD6sA9lz5Gc7IkRrPVUNf7Gc5%2FTusa%0A6x%2FzXew2d%2BvaQbQ%2FLruSNhrY%2B8rxJHR7grczmDWuCOOds5atj7XUP0X%2Bt6aN%0A6hCK3kTtTnr5EaxS09Qqn3vUqI5LUU%2FTrbUcKu3XnaY4dPbteh9ZA%2BdsB2zR%0Amo2xffl0yfmsuHvS1YLqdWS8Hw5vQ3JahIurN%2BU9y9ug2RqIS3d0XC3GzYEg%0ATK1qdz5o9Q2HOfnL5H0%2FQmqvKrlXq2v1p6Om6n0Qo143BO8UTJYOXTdPs7Bh%0AbOQlyQdmVd5slgfSsN5wtd6cXqcfdn0zUxi2NdeM%2FX3rGXO2W952lS5dm%2B3F%0A1fl83wiX0nU9lhfjzX4DV1NPmruO0sFutdesysY0KO%2FCto8GoeShE5s3VvBW%0AYbf3SlgVmtf6ZNoPJ9PbOx4s23lHvShEmHrBuD091aT%2BQG3axwkqHxx6Ol6O%0ArLrq4Z4o9bVVqXxr7EOvn5fET285U%2BYkP0FtaVXzghY133fGYXrvayKgIpJt%0A9Tnfl78lxESJdcAg2SPeAbzcVe4U%2BIcLy4v2wGfZubc6v98DUjoNPfwZooh2%0AcpIIjYpYtl5uMNF3Xc6Dzo%2FZT1DnPf2P%2BfAnwOVCSZXFIahPFuB%2FnB2rYrtz%0Ay0jIc%2B%2BjKGJtDRqIHpkf8CuOhQjyDPTSBPEm5i%2FXt0h9Kb79pr73dCaSgswn%0AQkjIJP3spVFINJnzxdMF4atT%2BaLfjLlEOCO%2FdLkM4u4hbTr48I3rpA4mjXk8%0AknCyDl4JOs7Oy80uzm%2BUXH6ThJE4PUeWSOYTPr4wFBKeSfatqmZuqDTGYkY4%0AtN%2BEI%2B0JTHiNr8fpBTPccxZ95Id3EGkT9tokv9hDlwAnoehx%2F1cQtULSGSpR%0AZ1hUeTuuSlGDqIviv2QFBG4%3D%0A""")
						.param("""facts_format""", """b64_zlib_yaml""")
			)
		.pause(2)
		.exec(http("request_3")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/aespe_security.rb")
			)
		.pause(115 milliseconds)
		.exec(http("request_4")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/sshkey.rb")
			)
		.pause(116 milliseconds)
		.exec(http("request_5")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/package.rb")
			)
		.pause(122 milliseconds)
		.exec(http("request_6")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/service.rb")
			)
		.pause(116 milliseconds)
		.exec(http("request_7")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/registration/meta.rb")
			)
		.pause(212 milliseconds)
		.exec(http("request_8")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/puppetd.rb")
			)
		.pause(164 milliseconds)
		.exec(http("request_9")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.ddl")
			)
		.pause(116 milliseconds)
		.exec(http("request_10")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.ddl")
			)
		.pause(118 milliseconds)
		.exec(http("request_11")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.rb")
			)
		.pause(123 milliseconds)
		.exec(http("request_12")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.rb")
			)
		.pause(121 milliseconds)
		.exec(http("request_13")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.ddl")
			)
		.pause(113 milliseconds)
		.exec(http("request_14")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.ddl")
			)
		.pause(114 milliseconds)
		.exec(http("request_15")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.rb")
			)
		.pause(113 milliseconds)
		.exec(http("request_16")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.rb")
			)
		.pause(146 milliseconds)
		.exec(http("request_17")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/util/actionpolicy.rb")
			)
		.pause(1)
		.exec(http("request_18")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_18)
						.fileBody("PE28BiggerCatalogCent5_request_18.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
