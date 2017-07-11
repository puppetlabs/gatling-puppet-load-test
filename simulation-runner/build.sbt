name := "gatling-puppet-load-test"

version := "0.1.1-SNAPSHOT"

scalaVersion := "2.11.5"

net.virtualvoid.sbt.graph.Plugin.graphSettings

libraryDependencies += "io.gatling" % "gatling-app" % "2.2.5"

libraryDependencies += "io.gatling.highcharts" % "gatling-charts-highcharts" % "2.2.5" exclude("io.gatling", "gatling-recorder")

libraryDependencies += "joda-time" % "joda-time" % "2.7"

mainClass in (Compile, run) := Some("com.puppetlabs.gatling.runner.PuppetGatlingRunner")

unmanagedClasspath in Runtime <+= (baseDirectory) map { bd => Attributed.blank(bd / "config") }

fork := true

javaOptions in run ++= Seq("-server",
   "-XX:+UseThreadPriorities",
   "-XX:ThreadPriorityPolicy=42",
   "-Xms512M",
   "-Xmx512M",
   "-Xmn100M",
   "-Xss10M",
   "-XX:+HeapDumpOnOutOfMemoryError",
   "-XX:+AggressiveOpts",
   "-XX:+OptimizeStringConcat",
   "-XX:+UseFastAccessorMethods",
   "-XX:+UseParNewGC",
   "-XX:+UseConcMarkSweepGC",
   "-XX:+CMSParallelRemarkEnabled",
   "-Djava.net.preferIPv4Stack=true",
   "-Djava.net.preferIPv6Addresses=false")
