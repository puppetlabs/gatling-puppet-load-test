TODO: write better docs and link to a github commit

Steps required to bring a Simulation class up to speed:

    - change the package name to: 
      package com.puppetlabs.gatling.node_simulations
    - add the following import statement:
      import com.puppetlabs.gatling.runner.SimulationWithScenario
    - the simulation class (of the name specified in the recording) should extend SimulationWithScenario
    - the requests ('request1, request2, etc) should be renamed depending on their associated endpoints so that reports can be generated
          node -> /production/node/agent.localdomain
          filemeta plugins -> /production/file_metadatas/plugins
          catalog -> /production/catalog/agent.localdomain
          filemeta mco plugins -> /production/file_metadatas/modules/pe_mcollective/plugins
          report -> /production/report/agent.localdomain

dependencies: 
    The target puppet master must have gcc and make installed in order for some gems, required by beaker, to compile.   
        
FUTURE

* Nice to have: rename requests
* Nice to have: generate unique node names to avoid possible cert caching perf discrepancies
