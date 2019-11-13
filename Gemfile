# frozen_string_literal: true

source ENV["GEM_SOURCE"] || "https://artifactory.delivery.puppetlabs.net/artifactory/api/gems/rubygems/"

gem "beaker", "~>4.0"
gem "beaker-abs", "~>0.1"
gem "beaker-aws"
gem "beaker-benchmark", "~>0.0"
gem "beaker-pe", "~>2.0"
gem "beaker-pe-large-environments", "~>0.3"
gem "beaker-puppet", "~>1.0"
gem "master_manipulator", "~>2.1"
gem "parallel", "~>1.6"
gem "rototiller", "~>1.0"
gem "rspec", "~>3.0"
gem "rubocop", "~> 0.67"
gem "scooter", "~>4.3"

group :test do
  gem "simplecov", "~> 0.17.0", require: false
end

group :development do
  gem "pry"
end

eval(File.read("#{__FILE__}.local"), binding) if File.exist? "#{__FILE__}.local" # rubocop:disable Security/Eval

gem "google-api-client", "~> 0.19.0"
gem "google-cloud", "~> 0.52.0"
