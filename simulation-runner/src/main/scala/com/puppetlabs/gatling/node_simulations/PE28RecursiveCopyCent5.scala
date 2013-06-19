package com.puppetlabs.gatling.node_simulations 
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._

class PE28RecursiveCopyCent5 extends com.puppetlabs.gatling.runner.SimulationWithScenario {

	val httpConf = httpConfig
			.baseURL("https://pe-centos6.localdomain:8140")
			.acceptHeader("pson, yaml, b64_zlib_yaml, raw")
			.connection("close")


	val headers_2 = Map(
			"Accept" -> """pson, dot, b64_zlib_yaml, yaml, raw""",
			"Content-Type" -> """application/x-www-form-urlencoded"""
	)

	val headers_19 = Map(
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
						.param("""facts""", """eNqdV1lzo7oSfr%2B%2FQtdPM%2BWxWQwYU3WqbrzvW7zFLy4BwmCzRRLefv2RgMR2%0AJjMPN65UgdQt9fL1102pVAL%2FxYl5FSLzgCxqTJM4RtQwxpGNDKMNLUr%2BA8AJ%0A%2BgkiBmCPAISIniN83PmRAQqSXC2L%2FFdI9xymsCM0CuIdQfiEsAFiVLJQSCOi%0Alf3Igr4dBdALU2l6jZEBJtRFOH2PIXXZmUJCsHBE2EQ4IgIxvdB4XvpcSQ98%0AkMje09ds8XPnLpM%2B4Cii%2FCmzmiDfC5PLzopCx9vv4sj3rKsBKMR7RJGdyrgQ%0A22eIUcAC4xvA03QtXfdiCk0fkR1zlnhRyGNSrpTVPB7vdvgQAvW3EHix9jd9%0AFusAkiNblFW1%2FPGfB9vyPXbqXU8uV8uyBH5kOQStkCIcY48gIJf1svQz0zIj%0A5glLjgf9MAlMnqJxFKLH67LUpjfdU8uCY0G6MyFBtseUhBPEQhRTwfdMgXkY%0Ap7cKmdiDfRbC9K8hiBmwCjEBJeQUnkLtEfgYaNsAPG2ZDtoxsFjuY9Sec5kl%0A8SE4%2Bb4XQ9vGiJBn%2FEoP%2BPXILnOG%2BUIin0G04ECfoEwkoMkOUVfkyqqYB4cb%0AtnOjgMkKn0Y%2BFEMc8SAUNEmTKt%2FdxKJOeSYeL%2FJ4%2FpgYL7wCv%2FGXH%2F0iHhWf%0AHeWA%2FIJVfnZafZ%2BA0spSNVc7w5h4N5TiRRRBp56tZyxArgEo7KgXIEJhEBeY%0A1CgKQT8JgVQFkmwoqqEooCRWmaosfjgTQCuPKlMQRUNsGHLNkBVDbRjVj4uf%0AIFdYjXiKS6oGFBtULSCZQJYBe9UUYMmlqghUEVQUIKoAMgArQLXAx1Es%2BwE8%0ARPgh%2B%2FK3%2BYPPEeUusgDm%2BOXYzUHLIZz5z3Z36ZNU1jMwRoSGkCf2DuF0I4l5%0AmHY2vKZO54Fg%2FICvNKKQcURBFVnhVcCofg%2B9g9FvofeJydyxPUIx8hGrL66a%0Ae%2Boyg1m5xDhiOCARtqIkpHe0M1dPHqZJeh3FSe7o59op4FFO1xh7hpy5hhw1%0AmQeh954gXlcFSYSWLladT4O4NXynwTyevD7x%2Fgf4q3JZYrjiBfSk9uBEufpp%0AJmf6BwsDGCY8WQl%2BQMMv0Aut8tc6%2Ff0%2BSdYLjzlwowSTe1AgtlyWx%2FRwRiCV%0AnECiGGFIvXBPrqzYgiff7gD%2BuO4PKP5TInLfLVaMGVraXgj9ZxV%2BbI8Vtf9j%0A%2FhM0Iox%2BLEY%2FgVctVVRZHIHGdAn%2Bx6i6Jna6t9yTZM9CeUc546lPPs59J4ix%0AlE1ScqnkqPni6TcJ%2Bex4CcYsCjmJoNBhjjG9z2p55BD9Q5kzYEaemlLRng%2FM%0AjkD2U7Iz6D02KpZH%2FXGP4f9p%2B9u%2B%2FJ2RucjTdSwXd5cNiwW6pJTFkgcr8v0t%0AjDhMjD2GsetZ5C7xtJJLsS4a8njepZ5WMqns8qyxGeBrl8sBYiNiYTYzZJ5m%0ACAS5tYClB%2FxIgZP3ahSySo7CAHGoMRzZicU1M8%2BJaxN4RGxQKbywv3plfIMN%0A6WhVRuytUX%2Fpxw3dPygjGcbeXK8dk22yoi0YacKyuOytDr0qPR9GM7XrDg6b%0A5XLywphuba%2FFq3acWJVtsdgtvta0TeRgz2rPuwtTVdTEf3tv3wQhxlpzVBsG%0A58rbeIFX2Gq1m%2BpmP%2FeK77OGRgfHYs8LWuamfhDdt4tZ0cZDd68fT0KvL4Sm%0ARZ2JLkxMfyM7bxtpcOL2t2fN2giK4VTtTfvFMawR29b09z1q1iaVMxPo1ds%2B%0Akfabbksc%2BftOY4CcoX92Y7pszyeee3kP8PmsBHvc0%2BLadWy9Hg4vI3xaJstr%0AODtu5y%2FDVnsoroLxcb2ctIaCMHNqvcWwPbB86hcv09f9GKn9mhRcnZ4zmI1b%0AaviGrUbDEsJTPF35ZNM6zZOmtZVXuBjbNXm7XR1w03nxao3W7Dp7cxvbuUI9%0AVwvs1N6XvrWg5upm6j2ysTvLq%2F%2F%2BuhUuletmIi8n2%2F0WrmehtAh8pesFtX6r%0AJluzuGomnQgNEylEJ7poruFNp7dXPakJrWtjOhsk09nt1RuuOkVfvShYmIXx%0ApDM71aXBUG25xymqHnxyOl6OtLbue31RGmjrSvXW3CfhoCiJ7%2BFqrixwcYo6%0A0roexm1iv5rWYfbPP%2FmUl%2FCBZQcT6qZl92X2SdtbPj586W45PDP2ywkdrLJG%0ABKY%2BpKxsg1w07bo7NkD%2BZZLMmIw4MPB8hvE5sruQftPk4T6tjof6Z%2BPBI5no%0AH8Md5y0%2BP3HmUnTx0Zb%2Fa4h%2B9lhRxPoGNBE50ihm5jqIMauFvrj%2B2db%2B0NEy%0AOrzTV0aVJbmqsI8CqYz85w%2BDj271zdcB4wf8DT9cLbmVvvY4RmetF9%2FZ9sh2%0ActlGktzZvl17%2FWDZnWq1GDnuVhklfVlso8aJ2sc332wpe1oU1MidyQt6m43b%0A6%2BGskbSCi79uwoZ1iRotv63G7UXvJCqs5g7zoqCRt2ZxOZcWph27%2FYB9avbU%0A96R2esHdysE5F73K8iqIo3P3Xd%2B7pw5Zjm1rvm3YrboDoSR0HE0%2FqcOb1Roc%0A%2B6i4vA3JRaYvQmUQiIPZwm8ufaE4ft2fF%2B3g2JSaPp7bzrzb0MN2%2FbIgx%2BnN%0Aua3s2cSJfW%2ByscVWqNtC4tlo5omR3m3K1%2BbwMq4ehqdB57x%2B6WwHb8vWrdnU%0A1gju14e3k1g%2FNzZuMHQHsDdSzNbwcoRN73QWtvoQRubpfRKR0J22D7VFda67%0AXasxfT1%2F1FMKlC%2FDTjoD8AGAfRVAzuePxZUPiJVqrcym34%2Fi4q3%2Bxr7SDDBt%0ALh7aP0eRocggnYDuw7EXPg3HKba%2BDrFfvsPQJfYya4x0sC%2BJWomP%2FBVD4iN%2F%0AWamJmiTyyd8QxX8BSf4Eaw%3D%3D%0A""")
						.param("""facts_format""", """b64_zlib_yaml""")
			)
		.pause(637 milliseconds)
		.exec(http("filemeta aespe security")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/aespe_security.rb")
			)
		.pause(116 milliseconds)
		.exec(http("filemeta ssh key")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/security/sshkey.rb")
			)
		.pause(115 milliseconds)
		.exec(http("filemeta app package")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/package.rb")
			)
		.pause(117 milliseconds)
		.exec(http("filemeta app service")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/service.rb")
			)
		.pause(118 milliseconds)
		.exec(http("filemeta registration meta")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/registration/meta.rb")
			)
		.pause(126 milliseconds)
		.exec(http("filemeta app puppetd")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/application/puppetd.rb")
			)
		.pause(10)
		.exec(http("filemeta loadtest puppet")
					.get("/production/file_metadatas/modules/loadtest/puppet")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
			)
		.pause(7)
		.exec(http("filemeta agent puppetd ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.ddl")
			)
		.pause(117 milliseconds)
		.exec(http("filemeta agent package ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.ddl")
			)
		.pause(124 milliseconds)
		.exec(http("filemeta agent puppetral")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.rb")
			)
		.pause(119 milliseconds)
		.exec(http("filemeta agent puppetd")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetd.rb")
			)
		.pause(118 milliseconds)
		.exec(http("filemeta agent service ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.ddl")
			)
		.pause(220 milliseconds)
		.exec(http("filemeta agent puppetral ddl")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/puppetral.ddl")
			)
		.pause(117 milliseconds)
		.exec(http("filemeta agent service")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/service.rb")
			)
		.pause(118 milliseconds)
		.exec(http("filemeta agent package")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/agent/package.rb")
			)
		.pause(637 milliseconds)
		.exec(http("filemeta action policy")
					.get("/production/file_metadata/modules/pe_mcollective/plugins/util/actionpolicy.rb")
			)
		.pause(5)
		.exec(http("report")
					.put("/production/report/pe-centos5.localdomain")
					.headers(headers_19)
						.fileBody("PE28RecursiveCopyCent5_request_19.txt")
			)

	setUp(scn.users(1).protocolConfig(httpConf))
}
