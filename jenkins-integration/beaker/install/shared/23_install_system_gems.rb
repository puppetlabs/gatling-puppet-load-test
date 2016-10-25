require 'json'

test_name 'Install System Gems'

def install_system_gem(host, gem_name)
  step "Install '#{gem_name}' gem"
  # Ensure it's the system ruby
  on(host, "/usr/bin/env gem install #{gem_name}")
end

step 'Install gems using system ruby'

gem_list = ENV['PUPPET_GATLING_SYSTEM_GEMS'].split(',')

gem_list.each do |gem_name|
  install_system_gem(master, gem_name)
end
