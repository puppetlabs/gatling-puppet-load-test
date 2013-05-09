package com.puppetlabs.gatling.node_simulations

import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._
import com.puppetlabs.gatling.runner.SimulationWithScenario

class PuppetDB(numRepetitions: Int) extends SimulationWithScenario {

	val httpConf = httpConfig
			.baseURL("https://pe-ubuntu-lucid:8140")
			.acceptHeader("pson, b64_zlib_yaml, yaml, raw")
			.connection("close")


	val headers_2 = Map(
			"Accept" -> """pson, b64_zlib_yaml, yaml, dot, raw""",
			"Content-Type" -> """application/x-www-form-urlencoded"""
	)

	val headers_19 = Map(
			"Accept" -> """b64_zlib_yaml, yaml, raw""",
			"Content-Type" -> """text/yaml"""
	)


	val scn = scenario("PuppetDB Node")
    .repeat(numRepetitions) {

		exec(http("request_1")
					.get("/production/file_metadatas/plugins")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
					.queryParam("""ignore""", """--- 
  - ".svn"
  - CVS
  - ".git"""")
			)
		.pause(6)
		.exec(http("request_2")
					.post("/production/catalog/pe-centos6.localdomain")
					.headers(headers_2)
						.param("""facts""", """eNqVV1mPozoTff9%2Bhb88zagnCRDWSFe62ZNusq%2FdL5EBB0gA08Zk%2B%2FXXBrqz%0AaO5Il1ZL4KVcrqpzTqVcLoP%2Fk9S6VLG1RzatT9I4RrReH2EH1etdaNPkfwCg%0Ac%2BwTSH0c1YEkiLWyIJclBYh6XRDqilGRZJU9oCxobICtj2CI6iBGZRtFFCdq%0AJcA2DBwcQj9i00cYpCipA%2FYKgB34bNERkSQzX5IqWkUSwY%2FcE9CJKCIx8RME%0ApIpeEX%2BWsl0RoiFMDtsA8y2KUhH4Xz5n48iGdGvBBDk%2BqYPqEZIqjmk18K0q%0AcyrOLFfzZdmOGCfUJSjZOmgH04Bub%2B7oFTm36ifbo09oCgM2SkmK8mEPEucE%0ACQpZwNiMr%2BpqNr5jodsmFIfxNkGE2cvikVppRNNykNq%2Bky1LUOBH6XnLnNn5%0A7jbGgW9f6oBC4iKKnJspdnzuN7s25dZKOxgkhRM42cHQD9jGGXL6xaV2n070%0AhyQ827Xho00%2FVim0AhaUWzDEilzRvhNwwuSwRdQT%2BIwhVURVZ5UgfaUhZDEh%0Alx1BrBRKNb1WqWlg2MzneMklPi3yw3NTJIWnKKtHPrvN3sSKnu1BEYs%2FjkJ2%0AG3Ytgp3U5hVZOAsdhyUw%2BZ0%2FomSUHlf924Lc5cS%2Fcpdlw6goN5fTmPohYslk%0AqXK4BUkTlOKq34VxDHkt5Jk9wbi4vFgxNNAr7IQ0zatWVOWamo%2FFkHpspJom%0ApJplqZpYflS%2F%2B84%2B88Hvmdua7IVgTPlbbpJeYnb0mHqIPNdjjAmLYEkVVbFW%0AnI%2B2oR9hcl%2F3N2%2B%2FQqoIxXVZ8G0WRUz48IABNPgx%2BwlamKAfi%2BFP4CugNVmC%0A%2FBkCRRIA%2BJuhVxZ6%2Fetj9eSBkLR7%2BMYeywC78%2FcpNk55ykvifZIophkSn7JU%0A1EVOQKXVkKcDrPL0gEkA6Q6TMF96QCRCwT3xqJWaVFQKZx0WMs5SJX7%2FXwH%2B%0AxUqycJFXwhVH7IhJe%2FGA4xzAd0bl%2B8MIChBjpe%2FDyppYkYyKWEGBWuHUkS%2B2%0AMCMVxho%2BDKI0tDjaR%2By034AWuhka7vjohoSH2Bax85064HWSfUBiewxlNk0J%0Ac8mvFcwV8zvHCSijXb4pF4jkEoLSlt88oTCMS2zRwktBIyaAS4FWr3Ep4Bog%0ACJlIPNXKUxafiI%2FTZ51BnKXH9iM3TzS0n1DN1EZo1SWj3mbKo9U7%2Bn1w68Dk%0AFh%2FkodjHBeLrX%2FiK05%2FYLY%2FulgnHHxTk4R6568h5SAYP9dbDvBar32HPshvC%0AKOWpZKEnXyDiCGLYzHS29M0hBRs9cEiumTbiOP4DwfMyQQ8OFSTmwAtPchEK%0Aj6nfs2Lnxyeek8ADYrpSarCnWRtdYUs82LUh%2B2o1G4PGeWod3ZqyuiruvH1A%0AhtkwPgPzw1o1B2u6Mq9%2BM4V2oPa76nUtDrvNAzEJGZjNt%2BveHC8tZ4aESD4t%0A3FNrY5oNOJvV5sJurOPIO7%2B6ycTUjqi9G3bowGcLjdFl49DunGykuL%2FS1hNl%0AwGpkHujuzBYuMFbf3SG2FhfBSf1%2BZ9Hr4%2BqwOVHb8evc4%2F53p235ZW4PZhvF%0A9y7NiW%2BIDbv9YcqN1sI%2FsQWDxqKqDdpDUzKH%2FW56keaDqWt3HMeSbdtRG0I4%0AURvv08Dp9Q6NZj%2F1m74bf7bNhooF0VfDfVUx529m%2B3X9cdob6kGNzjI9dJdL%0Aug4XL%2FtlX0PepCGoUxQtu%2FAyebFFuTU3T6PBRVY2ZB96s2tVPX4Gru%2B%2B96A7%0A2bReFgbB13WS6ov14HQKuoIDzZdpc%2BJm%2FraQe7LMlUr3Axr5b5P9Yuj1Egnt%0AaSNQBuZy4xJLMjfyMqCHjWtO1rpqeb23lbiZC4PPD5G2BLGzFGqveLU6SKt0%0AYSSvsV2b4tZQjRx%2FphxoW1wxwetir3cUa%2Bflh9599RvGaR9pbnJeBP64Ftri%0ASAkV1GoLmJLd8rLaBb2rev48HX1xQQ%2BvH8qge%2Frrr6JZiRGv8chNLqyTCeug%0AxUpuPL%2FH7e8hmwHnkeBlWWhuQBslB4pj1vzsEEGRjZ6Y%2FpFKC1UoKyqQHaBB%0ARlZAt4GkAl0Hil62NWAhgBDYqaAmAkcHggaQ%2FkBbD6D6ooCcwx5at5wo%2Fmtz%0AW6DUwynhMNXuR%2Fk3o1qQTX6rN2sgbO%2Beyh6bUz%2BBd60pV3u4f1D7QvbSyP9M%0AERcJqNuCLu6kb83JethvolQrYuHVE5Hlsf0FBpFdKX2RCPkNiVxsqZN9Djjw%0App1G8nL%2BaJ7GCw8b89F%2BOmhEh2MzOezT88yQerhnLl%2BmC7st7jXvoFNfTs1J%0A3FFN5HxawtAdL6OLIcXiZSAE7ZMYzM8ymk3lc4hHjjW6akevtR%2FM1M%2BjrltL%0ApWWO9hfDmeykvfpyCl5JZ0%2FnVpAea2v%2Fvff5fmrPNlqUvhudcTvSPfH9tbYy%0A2%2BRa7epOqA%2Ff%2Bv3pXnvzVqfuoNXaWNfpYtT8UIaO8NpvpT3tmI4%2FzsabO9y9%0ATGTZ1FU7WS3XXSzG85UT0HC30I%2FCeC6MFc3YhI3%2BG2qm761Zs7PHjfVeFqx1%0AY7keLpJQesed91QT%2FFpTXk5Sc3gmI%2BeYTMab11b7AE8tcx82o3gKex9DvTkw%0A3lqX99o0hGovlVRZn0vTL9DlEsnS%2FtDvlH73OwBHCQ7Q44%2BBXFTq4FlhbhL9%0A7%2Br8hPdbD6R%2BAZv3F%2FfVpX%2FJsJ3yjnULU%2BpljcKjUzB1maXbRtbl3JpIdF%2Fd%0AHFu3fpb3cfwcWReeepGUMPqgz83IPxXrp5s%3D%0A""")
						.param("""facts_format""", """b64_zlib_yaml""")
			)
		.pause(1)
		.exec(http("request_3")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/aespe_security.rb")
			)
		.pause(140 milliseconds)
		.exec(http("request_4")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/sshkey.rb")
			)
		.pause(142 milliseconds)
		.exec(http("request_5")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/package.rb")
			)
		.pause(146 milliseconds)
		.exec(http("request_6")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/service.rb")
			)
		.pause(133 milliseconds)
		.exec(http("request_7")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/registration/meta.rb")
			)
		.pause(155 milliseconds)
		.exec(http("request_8")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/puppetd.rb")
			)
		.pause(152 milliseconds)
		.exec(http("request_9")
					.get("/production/file_metadata/modules/concat/concatfragments.sh")
			)
		.pause(149 milliseconds)
		.exec(http("request_10")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.ddl")
			)
		.pause(142 milliseconds)
		.exec(http("request_11")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.ddl")
			)
		.pause(144 milliseconds)
		.exec(http("request_12")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.rb")
			)
		.pause(144 milliseconds)
		.exec(http("request_13")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.rb")
			)
		.pause(142 milliseconds)
		.exec(http("request_14")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.ddl")
			)
		.pause(130 milliseconds)
		.exec(http("request_15")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.ddl")
			)
		.pause(145 milliseconds)
		.exec(http("request_16")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.rb")
			)
		.pause(135 milliseconds)
		.exec(http("request_17")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.rb")
			)
		.pause(143 milliseconds)
		.exec(http("request_18")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/util/actionpolicy.rb")
			)
		.pause(1)
		.exec(http("request_19")
					.put("/production/report/pe-centos6.localdomain")
					.headers(headers_19)
						.fileBody("PuppetDB_request_19.txt")
			)
  }

	setUp(scn.users(1).protocolConfig(httpConf))
}
