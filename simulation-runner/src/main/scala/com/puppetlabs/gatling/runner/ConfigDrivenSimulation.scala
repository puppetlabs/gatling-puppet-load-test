package com.puppetlabs.gatling.runner

import io.gatling.core.Predef._
import io.gatling.http.Predef._

import com.puppetlabs.gatling.config.{NodeFeeder, PuppetGatlingConfig}
import io.gatling.core.structure.{ChainBuilder}

import scala.concurrent.duration._

/**
 * This class is the "main" Simulation class that we'll always point
 * Gatling at.  Its job is to wrap one or more puppet node simulations
 * based on the configuration specified in the config file
 */
class ConfigDrivenSimulation extends Simulation {

  val REPETITION_COUNTER: String = "repetitionCounter"
  val SLEEP_DURATION: String = "nextSleepDuration"

  def addSleeps(chain:ChainBuilder, sleepDuration:Int, totalNumReps:Int): ChainBuilder = {
    // This is kind of a dirty hack. Here's the deal.
    // In order to simulate real world agent runs, we need to sleep 30 minutes
    // in between each series of agent requests. That can be achieved
    // easily by adding a "pause" to the end of the run.
    // However, if we do that, then after the final series of requests, we'll sleep
    // for 30 minutes before the simulation can end, even though that is entirely
    // unnecessary. Since most of our jenkins jobs are going to run 2-6 sims,
    // that would mean we're sleeping for 1-3 extra hours and uselessly tying up the
    // hardware. Thus, we need to make the sleep conditional based on whether
    // or not we're on the final repetition.
    // Here we've replaced our "pause" with a Gatling "session function",
    // which basically just sets a session variable to check to see if
    // we are on the final repetition, and if not, sleep for 30 mins.
    //
    // In addition, simply sleeping for sleepDuration after a run causes issues
    // long runs, where start/end times will drift, and agent runs will start to
    // clump together. To solve this, the length of the pause is calculated to
    // be the difference between (start time + (repetition * sleep duration))
    // and the current time.
    //
    // That is, if the sleep duration is 30 seconds, and a run takes 5 seconds,
    // the agent will sleep for 25 seconds
    chain.exec((session) => {
      val repetitionCount = session(REPETITION_COUNTER).asOption[Int].getOrElse(0) + 1

      // Calculate the difference between when the next start time should be,
      // and now.
      // This has the bonus that the start times will never drift from run to
      // run. They will always be ((a multiple of sleepDuration) + the start time)
      val timeUntilNextRun = (session.startDate + sleepDuration * 1000 * repetitionCount) - System.currentTimeMillis()

      // To mimic real puppet agents, if the sleepDuration has passed,
      // run again immediately
      val nextSleepDuration = math.max(0, timeUntilNextRun)

      println(s"Agent ${session.userId} completed $repetitionCount of $totalNumReps repetitions.")

      session
        .set(REPETITION_COUNTER, repetitionCount)
        .set(SLEEP_DURATION, nextSleepDuration)
    }).doIf((session) => session(REPETITION_COUNTER).as[Int] < totalNumReps) {
      exec((session) => {
        val nextSleepDuration = session(SLEEP_DURATION).as[Long] / 1000.0

        println(s"This is not the last repetition; sleeping ${nextSleepDuration}s to match ${sleepDuration}s cycle")
        session
      }).pause((session) => session(SLEEP_DURATION).as[Long] milliseconds)
    }.doIf((session) => session(REPETITION_COUNTER).as[Int] >= totalNumReps) {
      exec((session) => {
        println("That was the last repetition. Not sleeping.")
        session
      })
    }
  }

  val config = PuppetGatlingConfig.configuration

  val httpProtocol = http
    .baseURL(config.baseUrl)

  val scns = config.nodes.map(node => {

    import node._

    val sim: SimulationWithScenario = simulationClass.newInstance

    val chainWithFailFast:ChainBuilder =
      // this wrapper causes the agent sims to exit the series of
      // of requests upon the first failure, rather than continuing
      // to send up the remaining requests for the agent run.
      exitBlockOnFail {
        exec(sim.scn)
      }


    val chainWithSleeps:ChainBuilder =
      addSleeps(chainWithFailFast, sleepDuration, numRepetitions)

    val feeder = NodeFeeder(nodeNamePrefix, numInstances).circular

    scenario(simulationClass.getSimpleName)
        .feed(feeder)
      .repeat(numRepetitions) {
        group((session) => simulationClass.getSimpleName) {
          chainWithSleeps
        }
      }.inject(rampUsers(numInstances) over rampUpDuration)
      .protocols(httpProtocol)
  })

//  scns.foreach(setUp(_))
    def getEnvVar(varName: String): String = {
        sys.env.getOrElse(varName, {
        throw new IllegalStateException("You must specify the environment variable '" + varName + "'!")
     })
    }

    if (sys.env.get("SUCCESSFUL_REQUESTS") != None)
        setUp(scns).assertions(
            global.successfulRequests.percent.gte(getEnvVar("SUCCESSFUL_REQUESTS").toDouble), details("PerfTestLarge").responseTime.max.lte(getEnvVar("MAX_RESPONSE_TIME_AGENT").toInt), global.allRequests.count.is(getEnvVar("TOTAL_REQUEST_COUNT").toLong)
        )
    else
        setUp(scns)
}
