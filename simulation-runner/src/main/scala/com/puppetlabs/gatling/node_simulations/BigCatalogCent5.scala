package com.puppetlabs.gatling.node_simulations 
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._

class BigCatalogCent5 extends com.puppetlabs.gatling.runner.SimulationWithScenario {

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
		.pause(11)
		.exec(http("request_2")
					.post("/production/catalog/pe-centos5.localdomain")
					.headers(headers_2)
						.param("""facts""", """eNqVV1mP4roSfr%2B%2FIpenGTGQPQSkI90mhH1vtuYFOYlDDNnaTth%2B%2FXEWlvT0%0AjHRbtBTb5dq%2FqnKlUmH%2Bi2PjygbGAZpRYxqHIYwajXFgwUajDcyI%2FIdhTsCN%0AIWkw9JNhCHSRH192Zowx9KOdl5Ay0LcDbCJ%2Fn9J4wASWhSGhl0oc1%2BC0hlBv%0ACFJD1hq1WimlsSlziE8QExT4lIyvKlU%2BP4vDCHlwZ4FryiDbxEEQ7ZzAo9LY%0A5PvBZYfILkwVB3uqEb0R4Rhml6zAA4iydwMTuNkiY0aNfpWtVnPRR4h96Hrg%0A8DwVqkqu8qdF1yGsmFRMQOTqV64P3wS%2Bjfa7MHCReW0wEcB7GEErpUFhBAwX%0Akt2reLEqZyLCxOCQMBVol75j%2BZ23QbyHgDzZcVWeq%2BZOQ1aDeTjrziu7Dq2C%0Ap0K4o1YH%2BEUvITtxAhL5IPH70%2FSn80kUeOGOpKF8oVB%2Bc04xVNQeEriUZ8kG%0ALsl1oKcnhKMYuEXVQOTQDTYmmKXxMSAOCEsMGtfi1mMnFf1Cka3TZbb5OHnS%0ApB%2BJq5KvTK4RAGx5wI8T1WOc2Ffq%2BRF0GS3AYYBBRP2Uq4gDKzZzN5VWozPA%0AkFlltjBTF0TU4949ohgB1489I2WY0VZkhZEspmYyvMEIAkOXisSYQqXGMTLH%0AiBLDyQyAjCAxssncMeQSw0IkwtClCZAIlotp3GCGScDTnSCEicL%2BnlxJBL1v%0A7nyxNFPsF9PzzWpGkJUKcvWY0i4BKImAF5Yo6SKGTD%2F2GY6qWWvQnygwFa7G%0AcYzA8WLpS03Ywcjh%2FlwY7lmaoeclG%2FlHotKEMJ1XAJW%2ByTAPUDtxMcFyhyWo%0A0GiaTt5zSN41c4OEm1CrUgBV%2BUIxcoIYkycoMhmvRaJWFXjmR1ZBGZ2mCQ4x%0AIjRktLjwPx8JHsJCblMcmCDaGTQWFqLasieA2SCMWBcZLEVTJofNyL5om%2FuR%0ArwlVnhZPqjYvqAVDTVouspxsIx%2B46VFizS3w6d60tXixMDGiIdWY1NCC6QRS%0A8VZiPM9x9zBQCc8capgBzWGpylUQEIXnyqcIMp3GHoPQQSZ5UhR2cirqLj9J%0A0CdVYSejKhV98Afzv9QaUMyC0LkSRCsCBa1JedBaGMRp38hN86L44VuZ4x72%0A0vr4BW6vYCs0jCqfa%2BKniXi88xNkuXr%2F5woU3x%2FSZH%2Flq96T8o%2BqQy%2FA1yiI%0A0hIqc%2FSKyIyad68pf%2Bs9iXtRBNMC0GCQqCoFC1JspKpVH%2B3lS1EpoCpPQQsS%0AE9Oml4nLzpnchQytPcyPNDVzgDi04iZlJ%2Blz1AKk5EoQ4lgEHCHtpqU3%2BtcU%0Axzeg8UdTHNGV1nzrh5rqHqSRAEI0V%2BvHeBuvIh0ECrssL3urQ68WnQ%2Bjmdx1%0ABofNcjl5o01tba25q3KcmOK2XO6W3%2BvKJrAxMtvz7sKQJTl2Pz7bN5YNsdIa%0A1YfeWfwYL%2FAKm3q7JW%2F2c1T%2BnGlKNDiWe8jTjU3zwDkfF0NUxkNnrx5PbK%2FP%0A%2BoYZ2ROVnRjuRrA%2FNvzglOjfnrXqI8D5U7k37ZfHoE4sS1E%2F97BVn4hnStBr%0Atl3C7zddnRu5%2B442gPbQPTthtGzPJ8i5fHr4fJa8Pe4pYf06Nt8Ph7cRPi3j%0A5dWfHbfzt6HeHnIrb3xcLyf6kGVndr23GLYHphu55cv0fT%2BGcr%2FOe1e7Zw9m%0AY132P7CpaSbrn8LpyiUb%2FTSPW%2BZWWOFyaNWF7XZ1wC37DdU1fXadfTjadi5F%0AyFE8K9X3rW8uImN1M9Qe2Vid5dX9fN%2ByF%2FG6mQjLyXa%2FBeuZzy88V%2Boir97X%0A64I5C2tG3AngMOZ9eIoWrTW4qdHtXY3rrH7VprNBPJ3d3tFw1Sm78kXC7MwP%0AJ53ZqckPhrLuHKewdnDJ6Xg5RvV1H%2FU5fqCsxdqttY%2F9QZnnPv3VXFrg8hR2%0A%2BHXTD9vEejfMw%2Byff55AJyhKgS6p3CuanyDP0FwRahKFCl%2BFrvwKNYJu8Hek%0ApZNDsdGPacktQpe7jxM%2F5j%2BTiQL%2BWIx%2BMqhWEWWBGzHadMn8j3aPOtfp3vLW%0AeAZhLlCo0u7aaRZbZjYdFsZNit5zgI%2FFzpZb%2Bpi1Tl6Cuaw7XJMGNYkciB9j%0AIfILY%2BFrjc2mPzoLJTVI4ZV7tw%2BIDTzkUrjOodXNO5fpIgp%2FEybEf5mis6K9%0Ao43wLx3xMcXT%2BOWdM6HJ22VCmg0r9HSXftEZ%2FxHzzBmKJCqvobQxTDwrSvWq%0AzD9Cmfg8Pyn6nDj4m4p0NQU9XfYSVMz0N9fe9sh2ctkGvNDZflx7fW%2FZnSr1%0AENrOVhrFfYFrQ%2B0UWccP19ClfVRm5cCZCYvoNhu318OZFuvexV23gGZeAk13%0A23LYXvROnERRfpiXWYV8tMrLOb8wrNDpe%2FQt15M%2F4%2FrpDXfFg30uI3F5ZbnR%0Aufup7p1ThyzHljnfapbetAHg2Y6tqCd5eDP1wbEPy8vbkFyE6I0VBx43mC3c%0A1tJly%2BP3%2FXnR9o4tvuXiuWXPu5rqt5uXBTlOb%2FZtZc0mduiiycbidF%2B12BhZ%0AcIa4QO22hGtreBnXDsPToHNev3W2g4%2Blfmu1lDUE%2B%2FXh48Q1z9rG8YbOAPRG%0AkqEPL0fQQqczu1WHIDBOn5OA%2BM60fagvanPV6Zra9P18R3Dso88YJvMcnU2A%0AqXK1%2FN0EfZrdge%2BlD8J8Oqfp%2B5KH%2F%2B%2FsZsZJsu9AHDnpa6w4U6SIL74CJIlr%0AbpgWJMcoCCkObEgfzCb88hxAiTSKpeSBXUqmhF9u8CspSqUCfn%2Bf9bgC9gtD%0A5b2LIgIePfTrC%2B4L7OAlRNmDppEO7RVOqWTjvJiM81VJFVU1neobHPcvfD0E%0Anw%3D%3D%0A""")
						.param("""facts_format""", """b64_zlib_yaml""")
			)
		.pause(1)
		.exec(http("request_3")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/aespe_security.rb")
			)
		.pause(117 milliseconds)
		.exec(http("request_4")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/sshkey.rb")
			)
		.pause(116 milliseconds)
		.exec(http("request_5")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/package.rb")
			)
		.pause(116 milliseconds)
		.exec(http("request_6")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/service.rb")
			)
		.pause(120 milliseconds)
		.exec(http("request_7")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/registration/meta.rb")
			)
		.pause(130 milliseconds)
		.exec(http("request_8")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/puppetd.rb")
			)
		.pause(136 milliseconds)
		.exec(http("request_9")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.ddl")
			)
		.pause(117 milliseconds)
		.exec(http("request_10")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.ddl")
			)
		.pause(118 milliseconds)
		.exec(http("request_11")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.rb")
			)
		.pause(124 milliseconds)
		.exec(http("request_12")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.rb")
			)
		.pause(121 milliseconds)
		.exec(http("request_13")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.ddl")
			)
		.pause(154 milliseconds)
		.exec(http("request_14")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.ddl")
			)
		.pause(114 milliseconds)
		.exec(http("request_15")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.rb")
			)
		.pause(116 milliseconds)
		.exec(http("request_16")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.rb")
			)
		.pause(327 milliseconds)
		.exec(http("request_17")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/util/actionpolicy.rb")
			)
		.pause(982 milliseconds)
		.exec(http("request_18")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_18)
						.fileBody("BigCatalogCent5_request_18.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
