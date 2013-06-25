package com.puppetlabs.gatling.node_simulations 
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._

class PE28BigTemplateHeavyCatalogCent5 extends com.puppetlabs.gatling.runner.SimulationWithScenario {

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
		.pause(11)
		.exec(http("catalog")
					.post("/production/catalog/pe-centos5.localdomain")
					.headers(headers_2)
						.param("""facts_format""", """b64_zlib_yaml""")
						.param("""facts""", """eNqVV1mP6rgSfr%2B%2Fwpenc8RAFpIQkEa6Tdh3aLbmBTmJQwLZ2nbYfv3YCXQH%0Apmek2xKt2C67Fn9fVblUKoH%2F4sS8CpF5QBatT5M4RrReH0c2qtfb0KLkPwCc%0AoJ8gUgfsEwDL91BILYRpHcSoZLFBRNSyH1nQt6MAemEq5kaEhjBAeaF0IWYH%0AFWICSsgppBNerFFo%2BojsTggTLwrZulSulNVs2fm0w3%2FVFOPIQoREWGQbeyFF%0A%2Fq%2F5b2BEGP1ajH4Dr1qqqLI4AsZ0Cf4H5HJN7HRv2dkE%2BV6YXHYBdxdQiPeI%0AIjuzyq4DHEU0HfCPnRtxb4SvSRdi%2Bwwx4pv9OvA0XUvnjwiHyA%2Fg4dsduaw9%0AfP03Vx%2FmoNCJsIWYBQWKE%2FS8aEWh4%2B13ceR71vXFaBSePByFAYtUncfFTizK%0AtKRrPjFtj1CMfAQJc6SglqvZyTHaMWsjnDNKvseeAWBHaBTETB%2B%2F8IImaVLl%0A4Qu0bcwiz52oymVJK0tylf30bD2JqRcgFrYEpyKFvBkWC1oGj7YXQj%2BHrHzU%0AqmVZAr8yUIIWu1ocY48gdol6Wfp9N4NPM0M5QAuIuuIffvQH8aj4pM9GxMIs%0A%2BtnJBtMzeQf3WAAWCfArteP3t98I5%2B%2BI%2BVbNxcQjuzi1it0GiXweTgf65H5V%0AGaXINQCFHY8BoTCIC0xmFIWgn4RAVoCk1WWlriqgJFZFEcjiI6wBTXbcDa5W%0AFZ%2B94KDMbM9EGfbw1cGI668ocrkiglEj28H13qKQrUybi3SGQYMmkCH1FHDY%0A%2FuQMfPYjgGHCJRKMMFtZjfi%2BP0AvtMqZQBQjDKkX7smVUBT8A7a88Albd3h8%0A0daKEg7XB0AyZtfBK80DaH3jTRTrolGXa2kMjXq1%2BiNHMlpnbGJG5lFJEJOx%0A%2BVFqRXnZnVErh0Op8GLB44L%2BwQx6jZneCXURfrjKmZjh%2FR5GsMquA0x9SJmB%0AQbYVJnsWwm%2FdYlkSy3cQcFTlMamXf4RkANld4OebzLzmu5i1IKXkE0lteE3D%0A%2BsLsnR%2FxPYzVzIiy9JM2uE%2BTTS5R8SX0NBOmRh0fUZNVtfz4id%2Bg55zl2hT9%0APpkp%2BH%2FzwRcGEoyZaT%2BCIDt5d2IZ3GOREtiHEMVU8D1TYJUmW87iE3qfCeK8%0AK0gitHSxeq9aZsQ2P1%2BsooiNDWgicqRRDObIQcwAC73cMHc1C6umVO5lgZxh%0ATLwbSp1k2aDTeL2IR0b4Ic9aCc%2FQO5hQNwX%2B880%2FYp%2BqTCNe%2FgIUyyrflK1b%0ArGKWlLJY8mBF%2Fh6FzFHLre8xjF3PIt8STzN3KXYdIc8H31JPM5nU3WfiYgKP%0AiNWwwhv7a1TGN2hIV0tupcPemf2ftd58Z9sj28llG0lyZ%2Ftx7fWDZXeq1WLk%0AuFtllPRlsY2ME7WPH77ZUva0KKiRO5MX9DYbt9fDmZG0gou%2FbkLDukRGy2%2Br%0AcXvRO4nKcTs%2FzIuCRj6axeVcWph27PYD1gv11M%2BkdnrD3crBORe9yvIqiKNz%0A91Pfu6cOWY5ta7417FbDgVASOo6mn9ThzWoNjn1UXN6G5CLTN6EyCMTBbOE3%0Al75QHL%2Fvz4t2cGxKTR%2FPbWfeNfSw3bgsyHF6c24rezZxYt%2BbbGyxFeq2kHg2%0AmnlipHeb8rU5vIyrh%2BFp0Dmv3zrbwceydWs2tTWC%2B%2FXh4yQ2zsbGDYbuAPZG%0AitkaXo6w6Z3OwlYfwsg8fU4iErrT9qG2qM51t2sZ0%2Ffzn38Wcs3KNwpkXun0%0AklxVWFsilZGvfkGF9QgvDUT%2BiKdmhx3xhb5zhI%2FPeeTB%2BbR63WGviozDla%2Fq%0AlbLrpfykrR3v61grAnkhv8M%2FCi1Idyaz6V%2FILGRijwT1VQtzWeqlmD1VWlbG%0A8g7qj1zI4exRlNrIWsDKvQVk2LZ%2FwPbRqozYyGi89WND9w%2FKSIaxN9drx2Sb%0ArGgLRpqwLC57q0OvSs%2BH0UztuoPDZrmcvLFuem2vxat2nFiVbbHYLb7XtE3k%0AYM9qz7sLU1XUxP%2F4bN8EIcZac1QbBufKx3iBV9hqtZvqZj%2F3ip8zQ6ODY7Hn%0ABS1z0ziI7sfFrGjjobvXjyeh1xdC06LORBcmpr%2BRnY%2BNNDhx%2B9uzZm0ExXCq%0A9qb94hjWiG1r%2BuceNWuTCudpr9H2ibTfdFviyN93jAFyhv7ZjemyPZ947uUz%0AwOezEuxxT4tr17H1fji8jfBpmSyv4Yzx8G3Yag%2FFVTA%2BrpeT1lAQZk6ttxi2%0AB5ZP%2FeJl%2Br4fI7Vfk4Kr03MGs3FLDT%2BwZRiWEJ7i6conm9ZpnjStrbzCxdiu%0Aydvt6oCbzptXM1qz6%2BzDNbZzhXquFtipvW99a0HN1c3Ue2Rjd5ZX%2F%2FN9K1wq%0A181EXk62%2By1cz0JpEfhK1wtq%2FVZNtmZx1Uw6ERomUohOdNFcw5tOb%2B96UhNa%0AV2M6GyTT2e3dG646RV%2B9KFiYhfGkMzs1pMFQbbnHKaoefHI6Xo60tu57fVEa%0AaOtK9dbcJ%2BGgKImf4WquLHBxijrSuhHGbWK%2Fm9Zh9uBqrhsnaXeaexZpf3sW%0A8W6BldQ7KTgh7kzgvMgaVLa6S79YL%2FGAeQyp5eafJzlCMq0e9MMkMLnuMesu%0AcwmgDoa87uZr8BO9YpeZw0z8p76PKXbZSEgIFtiJTEVEBGKyVvB56msmdTgn%0AkY3TYTb5tfItk37wFxz%2Fek5Rf6%2Bw9zz1eOd5BOZeeRFxYOD5jOFzZHfvmYXX%0A8Xs7%2FlTHs1RHI5qmnJdcd6%2FQPzdGzyG%2F944lVQOKDaoWkEwgy4ANNQVYcqkq%0AAlUEFQWIKoCIPzNUC2Rd6etb%2FAUv6BJ7WVatp2%2BRkqiVsleKyl8pZYm1G2qF%0AP1bqovgX0RcEaw%3D%3D%0A""")
			)
		.pause(6)
		.exec(http("filemeta aespe security")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/aespe_security.rb")
			)
		.pause(116 milliseconds)
		.exec(http("filemeta ssh key")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/sshkey.rb")
			)
		.pause(155 milliseconds)
		.exec(http("filemeta app package")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/package.rb")
			)
		.pause(114 milliseconds)
		.exec(http("filemeta app service")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/service.rb")
			)
		.pause(118 milliseconds)
		.exec(http("filemeta registration meta")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/registration/meta.rb")
			)
		.pause(123 milliseconds)
		.exec(http("filemeta app puppetd")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/puppetd.rb")
			)
		.pause(183 milliseconds)
		.exec(http("filemeta agent puppetd ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.ddl")
			)
		.pause(116 milliseconds)
		.exec(http("filemeta agent package ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.ddl")
			)
		.pause(118 milliseconds)
		.exec(http("filemeta agent puppetral")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.rb")
			)
		.pause(159 milliseconds)
		.exec(http("filemeta agent puppetd")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.rb")
			)
		.pause(125 milliseconds)
		.exec(http("filemeta agent service ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.ddl")
			)
		.pause(115 milliseconds)
		.exec(http("filemeta agent puppetral ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.ddl")
			)
		.pause(115 milliseconds)
		.exec(http("filemeta agent service")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.rb")
			)
		.pause(115 milliseconds)
		.exec(http("filemeta agent package")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.rb")
			)
		.pause(316 milliseconds)
		.exec(http("filemeta action policy")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/util/actionpolicy.rb")
			)
		.pause(839 milliseconds)
		.exec(http("report")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_18)
						.fileBody("PE28BigTemplateHeavyCatalogCent5_request_18.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
