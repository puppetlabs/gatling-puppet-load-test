job.parameters {
    stringParam('NUMBER_OF_HOURS', '2', 'Length of time to run the gatling simulation.')
    stringParam('AGENT_VERSION', '5.4.0', 'Version of puppet-agent to install for the simulation. (e.g. b203f0585865a53c6f3beb590250defc41192bf5 or 5.3.4)')
    stringParam('SERVER_VERSION', '5.2.0', 'Version of puppetserver to install for the simulation (e.g. 5.2.1.master.SNAPSHOT.2018.02.15T0124).')
    stringParam('PUPPET_REMOTE', 'git@github.com:puppetlabs/puppet', 'Puppet remote to use to drive the simulation (leave empty to use the default agent)')
    stringParam('PUPPET_REF', 'refs/tags/5.4.0', 'Puppet ref/branch to checkout for the simulation (leave empty to use the default agent).')
    choiceParam('JRUBY_VERSION', ['9k', '1.7'], 'Version of jruby to use in the simulation.')
    choiceParam('CATALOG_SIZE', ['MEDIUM', 'EMPTY'], 'Catalog to use in simulation.')
    choiceParam('NODE_COUNT', ['600', '100', '200', '300', '900', '1200', '1500', '1800'], 'Number of nodes (these were selected as they produce an even node distribution) to include in simulation.')
}
