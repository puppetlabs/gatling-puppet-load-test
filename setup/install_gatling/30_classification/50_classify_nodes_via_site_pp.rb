test_name "Classify Puppet agents on master"
skip_test 'Installing PE, not FOSS' unless ENV['BEAKER_INSTALL_TYPE'] == 'foss'

classify_foss_nodes(master)
setup_puppet_metrics_collector_for_foss
