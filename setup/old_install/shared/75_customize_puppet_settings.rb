require 'json'

test_name 'Configure settings on SUT'

def get_puppet_settings_from_env()
  ENV['PUPPET_GATLING_PUPPET_SETTINGS']
end

puppet_settings = JSON.parse(get_puppet_settings_from_env())

Beaker::Log.notify("INITIALIZING PUPPET SETTINGS to: #{puppet_settings}")

sections = puppet_settings.keys
sections.each do |s|
  Beaker::Log.notify("Updating puppet settings for section '#{s}'")
  puppet_settings[s].each do |setting, value|
    Beaker::Log.notify("In section '#{s}', setting '#{setting}' to '#{value}'")
    on(master, puppet("config set #{setting} #{value} --section #{s}"))
  end
end

puppet_conf = on(master, "cat /etc/puppetlabs/puppet/puppet.conf").stdout.chomp
Beaker::Log.notify("Modified puppet.conf:\n\n#{puppet_conf}\n\n")


