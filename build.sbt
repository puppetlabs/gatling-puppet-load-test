name := "gatling-puppet-scale-test"

version := "0.1.1-SNAPSHOT"

scalaVersion := "2.9.2"

resolvers ++= Seq("Excilys" at "http:..repository.excilys.com.content.groups.public",
                  "Local Maven Repository" at "file:.."+Path.userHome.absolutePath+"..m2.repository")

libraryDependencies += "com.excilys.ebi.gatling" % "gatling-app" % "1.5.0"

libraryDependencies += "com.excilys.ebi.gatling.highcharts" % "gatling-charts-highcharts" % "1.5.0"

mainClass in (Compile, run) := Some("com.excilys.ebi.gatling.app.Gatling")

fork := true

javaOptions in run ++= Seq("-server", "-XX:+UseThreadPriorities",
  "-XX:ThreadPriorityPolicy=42", "-Xms512M", "-Xmx512M", "-Xmn100M", "-Xss2M",
  "-XX:+HeapDumpOnOutOfMemoryError", "-XX:+AggressiveOpts",
  "-XX:+OptimizeStringConcat", "-XX:+UseFastAccessorMethods", "-XX:+UseParNewGC",
  "-XX:+UseConcMarkSweepGC", "-XX:+CMSParallelRemarkEnabled",
  "-XX:+CMSClassUnloadingEnabled", "-XX:SurvivorRatio=8",
  "-XX:MaxTenuringThreshold=1", "-XX:CMSInitiatingOccupancyFraction=75",
  "-XX:+UseCMSInitiatingOccupancyOnly",
  "-Dgatling.core.directory.simulations=./user-files/simulations",
  "-Dgatling.core.simulationClass=com.puppetlabs.gatling.simulation.PuppetDB",
  "-Dgatling.core.outputDirectoryBaseName=PE2_8",
  "-Dgatling.core.runDescription=\"This is a test\"")
