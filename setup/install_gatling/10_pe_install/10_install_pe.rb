require 'beaker-pe-large-environments'

test_name 'install PE for a scale environment' do
  skip_test 'Installing FOSS, not PE' unless ENV['BEAKER_INSTALL_TYPE'] == 'pe'
  perf_install_pe
end
