This is kind of a hack.  What this directory does is to allow you to run
`sbt run` from the command line to execute Gatling's "normal" Main class,
instead of our more common use case where we execute our custom Gatling
runner (via the `build.sbt` in the `simulation-runner` directory).

The main motivation for this is to provide a mechanism for generating
Gatling reports from a partial run.  If a run is cancelled or killed
before it completes, you'll end up with a directory that has a
`simulation.log` file in it, and nothing else.  In this case, gatling's 
Main class provides a command line argument `-ro` (`--reports-only`) that
allows you to tell it to generate the report HTML from the `simulation.log`
file without doing anything else.

However, because of what seems to me like some pretty screwy command-line
argument processing on the part of sbt, you need to put the arguments in
double quotes... so, e.g., an example usage might look like this:

    sbt "run -ro /path/to/incomplete/run/results/simulation-name-1457467932174"

There's got to be a better way to do all of this, or at least wrap this
nonsense in a shell script that abstracts out the sbt silliness, but I just
needed to get something working for now.
