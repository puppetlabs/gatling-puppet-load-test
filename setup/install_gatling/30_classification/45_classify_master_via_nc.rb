
test_name 'Classify Master' do
  skip_test 'Installing FOSS, not PE' unless ENV['BEAKER_INSTALL_TYPE'] == 'pe'
  classify_master_node_via_nc
end