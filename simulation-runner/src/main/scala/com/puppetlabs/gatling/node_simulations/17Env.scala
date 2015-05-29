package com.puppetlabs.gatling.simulation

import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
// import io.gatling.jdbc.Predef._
import com.puppetlabs.gatling.runner.SimulationWithScenario
import org.joda.time.LocalDateTime
import org.joda.time.format.ISODateTimeFormat

class 17Env extends SimulationWithScenario {

  val headers_3 = Map("Accept" -> "pson, b64_zlib_yaml, yaml, dot, raw")

  val headers_106 = Map(
    "Accept" -> "pson, yaml",
    "Content-Type" -> "text/pson", // add Connection Close...
    "Connection" -> "close")

//    val uri1 = "https://perf-bl15.delivery.puppetlabs.net:8140/production"

// val reportBody = ELFileBody("PE372_CatalogZero_request.txt")

  val chain_0 = exec(http("node")
        .get("/v2.0/environments")
        .pause(2)
        .get("/hankfan/resource_types/*")
        .pause(3)
        .get("/clifflu/resource_types/*")
        .pause(2)
        .get("/ericlin/resource_types/*")
        .pause(2)
        .get("/alex/resource_types/*")
        .pause(2)
        .get("/roman/resource_types/*")
        .pause(2)
        .get("/yenchen/resource_types/*")
        .pause(2)
        .get("/tinaho/resource_types/*")
        .pause(3)
        .get("/geoff/resource_types/*")
        .pause(2)
        .get("/rayyen/resource_types/*")
        .pause(2)
        .get("/production/resource_types/*")
        .pause(2)
        .get("/ericliao/resource_types/*")
        .pause(2)
        .get("/carol/resource_types/*")
        .pause(2)
        .get("/ryan/resource_types/*")
        .pause(3)
        .get("/otislin/resource_types/*")
        .pause(2)
        .get("/chenhsili/resource_types/*")
        .pause(2)
        .get("/cywu/resource_types/*")
        .pause(2)
        .get("/student/resource_types/*")
         
  val scn = scenario("17Env").exec(
    chain_0)

//  setUp(scn.inject(atOnceUsers(1))).protocols(httpProtocol)
}
