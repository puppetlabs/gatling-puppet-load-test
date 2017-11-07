source ENV['GEM_SOURCE'] || 'http://rubygems.delivery.puppetlabs.net'

gem 'beaker', '~>3.2'
gem 'beaker-hostgenerator', '0.8.0'
gem 'beaker-pe', '~>1.4'
gem 'beaker-pe-large-environments', '~>0.2'
gem 'scooter', '~>4.0'
gem 'rototiller', '~>1.0'

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
