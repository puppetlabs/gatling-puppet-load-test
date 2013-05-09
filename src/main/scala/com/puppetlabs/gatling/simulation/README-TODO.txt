Steps required to bring a Simulation class up to speed:

* Make it extend SimulationWithScenario instead of Simulation
* Give it a unique scenario name
* Make the constructor take an argument: numRepetitions:Int
* Call ".repeat" and pass it numRepetitions
* Nice to have: rename requests

Chris TODO:

X * allow the gatling params to be specified in the config file?
* request_N.txt files do not exist
* Figure out how to make config file path dynamic
* Document the config file format
* get rid of some of the useless log output
* Maybe rename SimulationWithScenario?  Maybe make it a trait?
* Separate node simulation classes from framework classes
* Figure out a pattern for generating variable node names (feeders?)
