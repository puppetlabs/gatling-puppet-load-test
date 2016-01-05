test_name 'Restart PE Puppet Server to pick up configuration changes'

on(master, 'service pe-puppetserver restart')
