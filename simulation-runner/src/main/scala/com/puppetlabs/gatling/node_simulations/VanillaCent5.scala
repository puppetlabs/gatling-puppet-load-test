package com.puppetlabs.gatling.node_simulations 
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._

class VanillaCent5 extends com.puppetlabs.gatling.runner.SimulationWithScenario {

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
						.param("""facts_format""", """b64_zlib_yaml""")
						.param("""facts""", """eNqVV9eO47gSfb9fwdtPM%2FDayrIsYIHbzjm1U%2FvFoCXKoq1kknL6%2BqUk5%2B1d%0A4A7QA4ssFatYp04d5fN58F8Sr89CuN4ii5nDOIoQM81%2BaCPTrEOL0f8AcIBe%0AjKgJ%2BE8AfBjEDt%2BICSIm%2BJj1jpCgP0ArsAofqcE6hMSOSGjHFgugj7iRqorl%0ABagiumNhBMbIQQQFFgJDDzInJH72ohUGFmSrNaTIxty3cIBECCMmeHgtRCgf%0ApcEJmVn6RhwxnB4gmooG3DAmNHOVBLiiLPSjFUXkkETKHVgoYCHVC15oQc8O%0AfYiDu3VqRXEYcG9SQS9IxcyTR9c2psziF5IlU8cB9NItl%2BeZJI8pNAHWDT1d%0ADRA7hmS3QswVE19FuSBxd3KxIGYe4wDvY4TtZFOEliEWnaegMV1leVrc6YcD%0APYqy3Wx1xe%2FkXy4ntYTxBkH6SEcsSOLtcB6dD%2BmOr8qaVrj9XTcpdQmFO3Tm%0A25%2F8X1npX2BFOltyLX1sHfn%2Fo9qn5yxbdDk4LUNJbiy%2Fz622P20O9VKEHHep%0A9uK2LNZR5cDs3be3rqkblhO00B3JE3YZ9evz7qgS1%2FyTN6%2FCinUKKzWvrkX1%0ASesgqrvleDvOCTr9ruamY2mytiO37XN4trR9XDp8kqaydY45rEzPgtg7NvfG%0Axj006LRvW%2BNlxa6VHQgloeHoxkHrXqxaZ9dGuemlS08y%2BxSUji92RhOvOvWE%0AXP9rc5zU%2FV1VqnpkbDvjZsUI6uXThO6GF%2Bcys0cDJ%2FLwYGGLtcCwhRjbaITF%0A0GhW5XO1e%2BoXt91Dp3GcfzaWne9p7VKt6nMEN%2FPt90EsHysL1%2B%2B6Hdjqqeta%0A97SDVXw4CkujC8P1YT8IaeAO69vSpDg23KZVGX4d%2F%2Fzz4wVWPoec9wQsn8Ur%0AL0xQo6uK%2FgyKR6nlQrEgS%2BBX1segFnBcRwRTBOSCUZB%2BX%2BuMPBzEp5UVE96H%0AbJWcZAIU8Fa0cLDJogjptXvvjaP9gFIOJpbywDNS3TPFvMM4B1iIUu40jAOW%0ABP4TzuEGpZuMxNf3fWhB2yb81VsTiaIpVky5ZMqqqVXM4rU3d4gEyHvOnjea%0Ace9bgjzeBwk9mFZIUF4tiHkMFfnxFHCqslxzQ2DkYos%2BLF5Wrlb8HgPGr%2Bdh%0A9bKSWb2QxiMArVD8scfDgIYeer0%2Bn1eenB2CknXFEAt6CfTK2V5G1vTsg49V%0AQn2UQT%2F64Ha9MADtOACiAkTDlBVTkUFeLIoikEVJube3%2FUN77yylx58q5c92%0AVDG8rdqTYYTHRmkXL%2BMZq8FQF6a5aWu2bRXZcdsbaU23s11Mp4NPjpG5PRfP%0A%2Bm5gKctcrpn7KumL0CHYqo%2Bbk7WmarH3va9fBCEierVX6vpH5bs%2FITNi1epV%0AbbEZ49x%2BVNFZZ5drYb%2B2XpS3ovt9Wit6v%2BtujN1BaLWFYG0xZ2AIg7W3kJ3v%0AhdQ5JPHXR9VSD4rBUGsN27k%2BLFHb1o39BlVLAyWhqla57lFps2jWxJ63aVQ6%0AyOl6Rzdi0%2Fp4gN3T3ifHo%2BpvSEuPSue%2B9bXdfvbIYRpPz8GIU9Fnt1bvijO%2F%0Av5tPB7WuIIycUmvSrXcsj3m50%2FBr00dauyT5Z6fldEb9mhZ8E6tSsYTgEA1n%0AHl3UDuO4ai3lGclFdkleLmdbUnU%2BcalSG51H325lOVYZdnXfTuP9bFsTtp5d%0A1kaLLuzG9Oztv5bCSTkvBvJ0sNws4XwUSBPfU5vYL7VrJdkaRcV13AhRN5YC%0AdGCT6hxeDHb5MuKSUDtXhqNOPBxdvnB31sh52kklwiiIBo3RoSx1ulrN3Q1R%0AcevRw%2B60Y6V5G7dFqaPPleKluomDTk4S98FsrE5Iboga0rwcRHVqf62t7ehG%0AVxEXBh8RBXl0HWNhhAhM2oKeOTf4PzRBAuLnaWvcNm7ElBESg2SDGLJ%2F8mqC%0ACqeNwdcTDzwOynggLxfVglKQCsjTMvfJzCVhyF7mdEapyXgu3Kfkq3rJJA6Y%0AYcJi6L2JlutAvTHVT1P1xrZh4ODNj2SbUPtNL2ji9b2kvy9hwI2H1clTnibo%0AJv6eBNAqVT4JT2ZvZtLGBO86J8md2yZJCfd7CKkDfexxUhgju%2FkirFY2PD%2B5%0AZeeIvzlgLiIviUWhh62ngsrSnQV9uH0jwpc7eaX9lPdYyKCXGIp8Yil34rtd%0Ac1qt9HIf1bI8zLFgIcKeh9XfVF52ezyil4FxjecIoyvjygVOmo3yC5EnwHnC%0A25O6jMLk1A9d0m8sm4CbYnaVsIlCu%2BrWRKhl9M13V%2BkvDv30HRQcMAkDP52E%0AV%2FDxCLPs4uSkFYyZm0LobdailY%2BDkKweSRkvoduIWgRHLNvLkgDXegDekeBX%0AKmh%2F%2F4jVrLJvnZgcCbcvR8ofdxjz5FIYq8a1OsmwQy%2BFxtHbeH%2FSyJJsvEaS%0ANQqyXzzwECLILPcpBOlRSIovfyvkXYsk57W4LPJ%2BjX%2BDChcCvya93wAX84om%0Aiz1QGU7B%2F7hYKomN5uU6svd28K%2FA4l8YGHpB7K%2Bfvojymg5UGxQtIK2BLAP%2B%0AqKvAkvNFEWgiUFQgagByXaYCzQI3RXO%2Fmn%2B4lfTb6u0LLM0mSYVjESZ1fu6K%0A%2F1caXhufIo4Am6bNrF6ry2%2Fc5QtCTInAe4knG1KBrjnRvC7dV9J7erLIntPH%0AbPG%2B87BJfyTclPx65oVrUd9o4SEV%2F1klcgAeMup%2BwVB6la%2Bl63O2Tffu9gc%2F%0AqeUbal8mhvSGrzetm2hC3u5psbiWV65angP4uTLGzQ1OqsJrm3xtfyTd8YcX%0A%2FpG0VLL9LsffgIhOEc4AYKaiLy%2Fq%2BUwOaokcLJRKkiLriSo0RfEvXcLydQ%3D%3D%0A""")
			)
		.pause(502 milliseconds)
		.exec(http("request_3")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/aespe_security.rb")
			)
		.pause(116 milliseconds)
		.exec(http("request_4")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/sshkey.rb")
			)
		.pause(119 milliseconds)
		.exec(http("request_5")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/package.rb")
			)
		.pause(115 milliseconds)
		.exec(http("request_6")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/service.rb")
			)
		.pause(114 milliseconds)
		.exec(http("request_7")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/registration/meta.rb")
			)
		.pause(121 milliseconds)
		.exec(http("request_8")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/puppetd.rb")
			)
		.pause(123 milliseconds)
		.exec(http("request_9")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.ddl")
			)
		.pause(122 milliseconds)
		.exec(http("request_10")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.ddl")
			)
		.pause(117 milliseconds)
		.exec(http("request_11")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.rb")
			)
		.pause(132 milliseconds)
		.exec(http("request_12")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.rb")
			)
		.pause(120 milliseconds)
		.exec(http("request_13")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.ddl")
			)
		.pause(117 milliseconds)
		.exec(http("request_14")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.ddl")
			)
		.pause(116 milliseconds)
		.exec(http("request_15")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.rb")
			)
		.pause(115 milliseconds)
		.exec(http("request_16")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.rb")
			)
		.pause(118 milliseconds)
		.exec(http("request_17")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/util/actionpolicy.rb")
			)
		.pause(331 milliseconds)
		.exec(http("request_18")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_18)
						.fileBody("VanillaCent5_request_18.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
