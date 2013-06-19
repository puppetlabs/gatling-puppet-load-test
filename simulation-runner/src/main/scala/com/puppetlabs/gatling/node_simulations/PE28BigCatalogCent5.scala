package com.puppetlabs.gatling.node_simulations 
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._

class PE28BigCatalogCent5 extends com.puppetlabs.gatling.runner.SimulationWithScenario  {

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
					.headers(headers_2)
						.param("""facts""", """eNqVV9mO6roSfb9f4dtP%2B4gNGUhCiHSk2808D83UvCCTOCSQqW2H6euPnQQI%0AnL23dBu1lJTLdrlctdZKsVgE%2F8Xx9iKE2z0yqTGOowhRwxiGFjKMJjQp%2BQ8A%0AR%2BjFiBiAPQJwQDhA3hFh4oaBAd7kklaS9Ldk7OhiGkPPAEf%2FBDFKbGYYmJBu%0AtpAgy8UGEI4QC2FEBc%2FdChEqRsmWQuqWzCDIc4P4vIlCzzUvuZ2kt2wcu9AL%0AYn%2BL2HpviwHfq6hqQLFAxQTSFsgyYK%2BaAky5WBGBKoKyAkQVQARkBagmqFTS%0ApbYhxNbzesMwSAMPED2F%2BLDxQraJJFdKIv9lIRDHIvCALmzonf19lIdXWJMO%0AZnnA3mof792opnt7ZSDDyJ3q1UO8jhe0AUNNmBfmncW%2BU6Gn%2FWCitp3efjWf%0Aj95DQpfWUrxoh5FZXhcK7cJnVVuFNnbN5rQ926qKGntf382rIERYqw%2Bqff9U%0A%2FhrO8AKbjWZdXe2mbuF7UtNo71DouH5ju%2FrYi87XeVvWhn1npx%2BOQqcrBFuT%0A2iNdGG29lWx%2FraTekcffnNSrAygGY7Uz7haGsEosS9O%2Fd6heHZVPzKHz0fSI%0AtFu1G%2BLA27VqPWT3vZMT0XlzOnKd87ePTyfF3%2BGOFlUvQ%2FNzv38f4OM8nl%2BC%0AyWE9fe83mn1x4Q8Py%2Fmo0ReEiV3tzPrNnulRr3Aef%2B6GSO1WJf9id%2BzeZNhQ%0Agy9s1mqmEByj8cIjq8ZxGtfNtbzAhciqyuv1Yo%2Fr9rtbrTUml8mXU1tPFeo6%0Amm8l8b53zRndLq5bvUNWVmt%2B8b4%2F18K5fFmN5PlovVvD5SSQZr6ntF2%2F2m1U%0AZXMSVbZxK0T9WArQkc7qS3jV6fVTj6tC41IbT3rxeHL9dPuLVsFTzwoWJkE0%0Aak2OH1KvrzacwxhV9h45Hs4HWl123a4o9bRluXKt7%2BKgV5DE72AxVWa4MEYt%0AafkRRE1ifW7N%2FeTvv9Oqslm%2FbVyySVuCdQQJPcQqzIYeQalLHFHX5zbRUCTg%0AhDEm6UAEqcPMQkywwFqUlXJIBLJ1A%2BPZdLd4oQm9nEf6nrymxvvIwyd5wGFI%0A%2BVO6rxtQhFngHB%2FeEHXEn174k7hUzMe7seCFj2dG%2B9ti%2Fcx630QBDYlaSva2%0AQh%2B6QX4WQSwHFp8oK5r2yBHCD1CQOPxk3ZzmLQ9NlZIsgR8pqoEGDzXCLmEo%0AUNJL0l9vtz73ITlsePB8kqqWbv9ZvPzEGyfkeU9Onx48gpaFESG3iVJFLkks%0AGIYUkpwBYgqWBuhzQMvFuGEg%2BAc0TDxhvEOQPE4jlqQ7%2FkQ4ZBknITbDOKB8%0A88yONvnjs0OmdjMmNPQ3MKbOhuXUfi4qHwYxz2uMc4D6E3QCs5Q6eGRruYRa%0AiJjYZXeTLF9jlzf6BBh5LEwE1FIF%2FGi6AfSyvEbOhbjsXn8Xq%2Bm5bAUTYfrH%0AWkj5iVx88LbhVUEo9KM3tszMiUE3DoBUBqJilGVD1UFRrIgikEWpnFVnpFG4%0A9RDZ5CumXFLfnpiGp8TdZYRjAArxDlFkJT4oYKwWBj7isbOzWLHJE%2FCr%2BT5n%0ATTbBZmd1g13iwkO%2BMkoxwLg%2ByyczyxsLiGUuDcdhRcFT7xJoAFfTtScrX93L%0A2dk6Pty%2FLJWjtZdb7bDq90AtxFGIIT9BvkIfK6R0XpQrCkuTVEKe%2BlQCJgsi%0AgLwTkqtOhsII8RWDHbkQivxfHOzFwwBp7eRzyNwpjlEOCHnFRgwDeLPnKkT7%0AV4UwMsa%2FIOOLKTeS1w4nhEnj3bPXHbIendehJLfWX5dO15%2B3x1o1QrazVgZx%0AVxabqHak1uHL2zaUHS0IauhM5Bm9TobNZX9Sixv%2B2VvWYc08h7WG11Sj5qxz%0AFBVGcPtpQdDIV70wn0qzrRU5XZ%2Bpqo76HVeP77hd3tunglueXwRxcGp%2F6zvn%0A2CLzoWVO1zWr8WFDKAktW9OPav9qNnqHLirMr31ylum7UO75Ym8y8%2BpzTygM%0AP3enWdM%2F1KW6h6eWPW3X9KD5cZ6Rw%2FhqXxfWZGRHnjtaWWIj0C0hdi00ccVQ%0Ab9flS71%2FHlb2%2FWOvdVq%2Bt9a9r3njWq9rSwR3y%2F3XUfw41VaO33d6sDNQto3%2B%0A%2BQDr7vEkrPU%2BDLfH71FIAmfc3FdnlanutM3a%2BPN0Iy%2BfxnckVEUxV4hZ06Rl%0A86Yo4scK1BE50DACU2QjjAITgbEHKWscP%2BvME4yIe00rkrV06%2BMOcL4bhDjX%0Az%2FpjBO6fRuQbvJkvUC2Khlgz5KohK4ZaM25qMKtx13oq0GdWZlRBk37K4SdH%0AqDy%2B6Le6v1FLIiETQnlISIcpvjQlD%2FBLMYtthZ7agVnuyjpvvjPQk0TN4JVe%0A%2BCoj6iCcvKcNY4DX7nkRHfD5aAzt%2F4Cfzzeb8gZYpKG%2BXGiKM%2ByGnr4cMpEQ%0AuN8x4ml%2Fk0Ro6mLFftRUejZNKWfO3O1OwnduEW8I92P6Fwc59GM2%2BAu4lWJZ%0AlcUBqI3n4H%2BM9atiq33N08%2F%2FKxYirkYiAorIfrmE3ygAn%2BE2vtgY8QyVFZGF%0AAAYfz%2FSTMgaynm43nUhDmty6KrIoyveZEJuOS1EC7owSyhklPCr990Wew1bG%0ABJyPNUm78eVzMcBdQnq5oEJiQ9%2F1GNJOkdXOvtfSSLNufQn0dsSUGp%2BIlV8u%0AF4o8cYou3lvwwR%2BGyS6yqJTEogsZv9%2FfgpCf39hhGDmuSR4eT5bMi91hwKnn%0A4fVkSb2e2vXXIjDTpInkfkjZ20fivzWgeIclJs1NJ99AL%2BIjxgwB6S%2FVA4fB%0ArHaeYJAjDstd9kXN9WP2Gc1lZCqY2OgmeWJ4xOa8Qs0Li6Jz5KaywEjkU1HU%0AilxYqYbIhVWpoiuyJHJ9ZYjiPy%2B0BGY%3D%0A""")
						.param("""facts_format""", """b64_zlib_yaml""")
			)
		.pause(832 milliseconds)
		.exec(http("filemeta aespe security")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/aespe_security.rb")
			)
		.pause(118 milliseconds)
		.exec(http("filemeta ssh key")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/sshkey.rb")
			)
		.pause(118 milliseconds)
		.exec(http("filemeta app package")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/package.rb")
			)
		.pause(125 milliseconds)
		.exec(http("filemeta app service")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/service.rb")
			)
		.pause(176 milliseconds)
		.exec(http("filemeta registration meta")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/registration/meta.rb")
			)
		.pause(135 milliseconds)
		.exec(http("filemeta app puppetd")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/puppetd.rb")
			)
		.pause(174 milliseconds)
		.exec(http("filemeta agent puppetd ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.ddl")
			)
		.pause(125 milliseconds)
		.exec(http("filemeta agent package ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.ddl")
			)
		.pause(124 milliseconds)
		.exec(http("filemeta agent puppetral")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.rb")
			)
		.pause(125 milliseconds)
		.exec(http("filemeta agent puppetd")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.rb")
			)
		.pause(119 milliseconds)
		.exec(http("filemeta agent service ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.ddl")
			)
		.pause(116 milliseconds)
		.exec(http("filemeta agent puppetral ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.ddl")
			)
		.pause(116 milliseconds)
		.exec(http("filemeta agent service")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.rb")
			)
		.pause(116 milliseconds)
		.exec(http("filemeta agent package")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.rb")
			)
		.pause(129 milliseconds)
		.exec(http("filemeta action policy")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/util/actionpolicy.rb")
			)
		.pause(800 milliseconds)
		.exec(http("report")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_18)
						.fileBody("PE28BigCatalogCent5_request_18.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
