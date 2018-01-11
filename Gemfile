source ENV['GEM_SOURCE'] || 'https://artifactory.delivery.puppetlabs.net/artifactory/api/gems/rubygems/'

gem 'beaker', '~>3.2'
gem 'beaker-pe', '~>1.4'
gem 'beaker-pe-large-environments', '~>0.2'
gem 'scooter', '~>4.0'
gem 'rototiller', '~>1.0'

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
