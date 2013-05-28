name := "gatling-puppet-agent-capture"

version := "0.1.1-SNAPSHOT"

scalaVersion := "2.9.2"

libraryDependencies += "com.excilys.ebi.gatling" % "gatling-recorder" % "1.5.0" exclude("org.scala-lang", "scala-compiler")

libraryDependencies += "com.excilys.ebi.gatling" % "gatling-app" % "1.5.0"

libraryDependencies += "com.excilys.ebi.gatling.highcharts" % "gatling-charts-highcharts" % "1.5.0"

resolvers += "Local Maven Repository" at "file://"+Path.userHome.absolutePath+"/.m2/repository"

resolvers += "Excilys" at "http://repository.excilys.com/content/groups/public"

mainClass in (Compile, run) := Some("com.excilys.ebi.gatling.recorder.GatlingRecorder")

fork := true

javaOptions in run ++= Seq("-server", "-XX:+UseThreadPriorities",
  "-XX:ThreadPriorityPolicy=42", "-Xms512M", "-Xmx512M", "-Xmn100M", "-Xss2M",
  "-XX:+HeapDumpOnOutOfMemoryError", "-XX:+AggressiveOpts",
  "-XX:+OptimizeStringConcat", "-XX:+UseFastAccessorMethods", "-XX:+UseParNewGC",
  "-XX:+UseConcMarkSweepGC", "-XX:+CMSParallelRemarkEnabled",
  "-XX:+CMSClassUnloadingEnabled", "-XX:SurvivorRatio=8",
  "-XX:MaxTenuringThreshold=1", "-XX:CMSInitiatingOccupancyFraction=75",
  "-XX:+UseCMSInitiatingOccupancyOnly",
  "-Dgatling.recorder.keystore.path=./target/tmp/ssl/gatling-proxy-keystore.jks",
  "-Dgatling.recorder.keystore.passphrase=puppet")
