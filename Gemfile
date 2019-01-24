source ENV['GEM_SOURCE'] || 'https://artifactory.delivery.puppetlabs.net/artifactory/api/gems/rubygems/'

gem 'beaker', '~>4.0'
gem 'beaker-benchmark', '~>0.0'
gem 'beaker-pe', '~>2.0'
gem 'beaker-aws'
gem 'beaker-abs', '~>0.1'
gem 'beaker-pe-large-environments', '~>0.3'

# scooter 4.3.1 caused authentication issues
# see https://tickets.puppetlabs.com/browse/PE-25817
# see also https://github.com/puppetlabs/scooter/pull/122
# TODO: revert to '~>4.3' when the issue has been resolved
gem 'scooter', '=4.3.0'
gem 'rototiller', '~>1.0'
gem 'rspec', '~>3.0'

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

gem 'google-cloud', '~> 0.52.0'
gem 'google-api-client', '~> 0.19.0'
