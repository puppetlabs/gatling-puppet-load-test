TODO: write better docs and link to a github commit

Steps required to bring a Simulation class up to speed:

* Make it extend SimulationWithScenario instead of Simulation
* Give it a unique scenario name
* Make the constructor take an argument: numRepetitions:Int **NOTE** this may not be required in the future; there may be a way to handle this programatically from the runner class
* Call ".repeat" and pass it numRepetitions
* Nice to have: rename requests
* Nice to have: generate unique node names to avoid possible cert caching perf discrepancies
