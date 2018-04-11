package com.puppetlabs.gatling.node_simulations
import com.puppetlabs.gatling.runner.SimulationWithScenario
import org.joda.time.LocalDateTime
import org.joda.time.format.ISODateTimeFormat
import java.util.UUID

import scala.concurrent.duration._
import scala.io.Source._
import scala.util.parsing.json._

import io.gatling.core.Predef._
import io.gatling.http.Predef._

class PerfTestLarge extends SimulationWithScenario {

	val reportFeeder = Array(
                         Map("reportFile" -> "NoChangesReport_0006_request.txt"),
                         Map("reportFile" -> "FailureReport_0006_request.txt"),
                         Map("reportFile" -> "CorrectiveChangeReport_0006_request.txt"),
                         Map("reportFile" -> "IntentionalChangeReport_0044_request.txt")
                       ).circular

	val staticFacts  = scala.io.Source.fromFile("user-files/facts/IrvingFactsChange_facts_raw.txt").mkString
	val factFeeder  = csv("user-files/facts/IrvingFactsChange_custom_facts.csv")
	val hostFeeder  = csv("user-files/facts/IrvingFactsChange_custom_hostf.csv").circular

	val baseHeaders = Map("Accept" -> "application/json, text/pson",
		"Accept-Encoding" -> "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
		"User-Agent" -> "Puppet/5.3.3 Ruby/2.4.2-p198 (x86_64-linux)")

	val headers_0 = baseHeaders ++ Map("X-Puppet-Version" -> "5.3.3")

	val headers_6 = baseHeaders ++ Map(
		"Connection" -> "close",
		"Content-Type" -> "application/json",
		"X-Puppet-Version" -> "5.3.3")

	val scn = scenario("perf_test_large")
	    .feed(reportFeeder)
		.feed(factFeeder)
		.feed(hostFeeder)
		.exec(http("node")
			.get("/puppet/v3/node/${node}?environment=production&transaction_uuid=feaf75a3-c82c-4e06-9d02-5387f14034a0&fail_on_404=true")
			.headers(headers_0))
		.pause(103 milliseconds)
		.exec(http("filemeta pluginfacts")
			.get("/puppet/v3/file_metadatas/pluginfacts?environment=production&links=follow&recurse=true&source_permissions=use&ignore=.svn&ignore=CVS&ignore=.git&ignore=.hg&ignore=%2A.pot&checksum_type=md5")
			.headers(headers_0))
		.pause(1)
		.exec(http("filemeta plugins")
			.get("/puppet/v3/file_metadatas/plugins?environment=production&links=follow&recurse=true&source_permissions=ignore&ignore=.svn&ignore=CVS&ignore=.git&ignore=.hg&ignore=%2A.pot&checksum_type=md5")
			.headers(headers_0))
		.pause(1)
		.exec(http("locales")
			.get("/puppet/v3/file_metadatas/locales?environment=production&links=follow&recurse=true&source_permissions=ignore&ignore=.svn&ignore=CVS&ignore=.git&ignore=.hg&ignore=%2A.pot&ignore=config.yaml&checksum_type=md5")
			.headers(headers_0))
		.pause(1)
		.exec(http("catalog")
			.post("/puppet/v3/catalog/${node}?environment=production")
			.headers(headers_0)
			.formParam("environment", "production")
			.formParam("facts_format", "application/json")
			.formParam("facts", "%7B%22name%22%3A%22${node}%22%2C%22values%22%3A%7B" + "${Fact}" + "${HostFact}" + staticFacts)
			.formParam("transaction_uuid", "feaf75a3-c82c-4e06-9d02-5387f14034a0")
			.formParam("static_catalog", "true")
			.formParam("checksum_type", "md5.sha256")
			.formParam("fail_on_404", "true"))
		.pause(2)
		.exec(http("filemeta mco plugins")
			.get("/puppet/v3/file_metadatas/modules/puppet_enterprise/mcollective/plugins?environment=production&links=manage&recurse=true&source_permissions=ignore&checksum_type=md5")
			.headers(headers_0))
		.pause(4)
		.exec((session:Session) => {
			session.set("reportTimestamp",
				LocalDateTime.now.toString(ISODateTimeFormat.dateTime()))
		})
		.exec((session:Session) => {
			session.set("transactionUuid",
				UUID.randomUUID().toString())
		})
		.exec(http("report")
			.put("/puppet/v3/report/${node}?environment=production&")
			.headers(headers_6)
			.body(ElFileBody("${reportFile}")))

}
