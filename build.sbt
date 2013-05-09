name := "gatling-puppet-scale-test"

version := "0.1.1-SNAPSHOT"

scalaVersion := "2.9.2"

resolvers ++= Seq("Local Maven Repository" at "file://"+Path.userHome.absolutePath+"/.m2/repository",
                  "Excilys" at "http://repository.excilys.com/content/groups/public"
                  )
//
//libraryDependencies += "com.excilys.ebi.gatling" % "gatling-app" % "1.5.0-SNAPSHOT"
//
//libraryDependencies += "com.excilys.ebi.gatling.highcharts" % "gatling-charts-highcharts" % "1.5.0" exclude("com.excilys.ebi.gatling", "gatling-app") exclude("com.excilys.ebi.gatling", "gatling-core") exclude("com.excilys.ebi.gatling", "gatling-charts") exclude("com.excilys.ebi.gatling", "gatling-http") exclude("com.excilys.ebi.gatling", "gatling-jdbc") exclude("com.excilys.ebi.gatling", "gatling-parent") exclude("com.excilys.ebi.gatling", "gatling-metrics") exclude("com.excilys.ebi.gatling", "gatling-recorder") exclude("com.excilys.ebi.gatling", "gatling-redis")

libraryDependencies += "com.excilys.ebi.gatling" % "gatling-app" % "1.5.0"

libraryDependencies += "com.excilys.ebi.gatling.highcharts" % "gatling-charts-highcharts" % "1.5.0"



//mainClass in (Compile, run) := Some("com.excilys.ebi.gatling.app.Gatling")
mainClass in (Compile, run) := Some("com.puppetlabs.gatling.runner.PuppetGatlingRunner")

fork := true

javaOptions in run ++= Seq("-server", "-XX:+UseThreadPriorities",
  "-XX:ThreadPriorityPolicy=42", "-Xms512M", "-Xmx512M", "-Xmn100M", "-Xss2M",
  "-XX:+HeapDumpOnOutOfMemoryError", "-XX:+AggressiveOpts",
  "-XX:+OptimizeStringConcat", "-XX:+UseFastAccessorMethods", "-XX:+UseParNewGC",
  "-XX:+UseConcMarkSweepGC", "-XX:+CMSParallelRemarkEnabled",
  "-XX:+CMSClassUnloadingEnabled", "-XX:SurvivorRatio=8",
  "-XX:MaxTenuringThreshold=1", "-XX:CMSInitiatingOccupancyFraction=75",
  "-XX:+UseCMSInitiatingOccupancyOnly")
