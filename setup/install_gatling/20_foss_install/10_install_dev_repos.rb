require 'net/http'

test_name 'install Puppet dev repos' do
  skip_test 'Installing PE, not FOSS' unless ENV['BEAKER_INSTALL_TYPE'] == 'foss'

end
