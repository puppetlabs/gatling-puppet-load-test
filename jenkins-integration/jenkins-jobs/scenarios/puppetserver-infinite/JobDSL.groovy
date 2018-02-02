job.parameters {
    stringParam('NUMBER_OF_HOURS', '2', 'Length of time to run the gatling simulation.')
    choiceParam('CATALOG_SIZE', ['MEDIUM', 'EMPTY'], 'Catalog to use in simulation.')
    // NODE_COUNT is offered as a list because gatling will not handle values that don't divide 1800 evenly (multiples of 300 also seem fine, which is why 1200 and 1500 are also there).
    choiceParam('NODE_COUNT', ['600', '100', '200', '300', '900', '1200', '1500', '1800'], 'Number of nodes to include in simulation.')
}
