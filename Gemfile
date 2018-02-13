source ENV['GEM_SOURCE'] || 'https://artifactory.delivery.puppetlabs.net/artifactory/api/gems/rubygems/'

gem 'beaker', :git => 'https://github.com/puppetlabs/beaker.git', :branch => 'fix/master/BKR-487_preserved_hosts_yml_fix'
gem 'beaker-benchmark', '~>0.0'
gem 'beaker-pe', '~>1.4'
gem 'beaker-pe-large-environments', '~>0.2'
gem 'scooter', '~>4.0'
gem 'rototiller', '~>1.0'
gem 'rspec', '~>3.0'

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
