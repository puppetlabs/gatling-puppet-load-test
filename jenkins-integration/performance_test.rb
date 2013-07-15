require 'json'
require './tester.rb'

def extract_settings(json)
  settings = {}

  master_info = json["master"]
  raise 'Master information is required' unless master_info
  if master_info.is_a? String
    settings[:master_hostname] = master_info
    settings[:puppet_master] = master_info
    settings[:master_ip] = nil
  elsif master_info.is_a? Hash
    settings[:master_hostname] = master_info["hostname"]
    settings[:master_ip] = master_info["ip"]
    settings[:puppet_master] = master_info["ip"]
  end

  # Default value taken from puppet-acceptance/options_parsing.rb
  settings[:ssh_keyfile] = json["ssh-keyfile"] || "~/.ssh/id_rsa"

  settings[:systest_config] = File.join(ENV['PWD'], "gatling-perf-master.cfg")

  return settings
end

json = JSON.parse(File.read(File.join(ENV['PWD'], ARGV.first)))
settings = extract_settings(json)
steps = json["steps"]
raise 'Job "steps" are required' unless steps

tester = Puppet::PerformanceTest::Tester.new(settings)

steps.each do |step|
  if step.is_a? String
    tester.perform(step)
  elsif step.is_a? Hash
    tester.perform(step.first[0], step.first[1])
  end
end
