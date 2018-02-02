job.parameters {
    stringParam('NUMBER_OF_HOURS', '2', 'Length of time to run the gatling simulation.')
    choiceParam('CATALOG_SIZE', ['MEDIUM', 'EMPTY'], 'Catalog to use in simulation.')
    choiceParam('NODE_COUNT', ['600', '100', '200', '300', '900', '1200', '1500', '1800'], 'Number of nodes to include in simulation.')
}
