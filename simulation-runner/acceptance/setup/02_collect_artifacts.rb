# 02_collect_artifacts.rb
# Collect artifacts from machines
# Brian Cain {brian.cain@puppetlabs.com}

require 'csv'
require 'json'

def get_facter_data
  result = on master, "facter"
  result.stdout
end

def save_data(facter_data, data_hash, config)
  simulation_dir = File.join("puppet-gatling", config.simulation_id)
  unless File.exist?(simulation_dir)
    FileUtils.mkdir_p simulation_dir
  end

  File.open(File.join(simulation_dir, 'facter-data.txt'), 'w') { |file| file.write(facter_data) }
  CSV.open(File.join(simulation_dir, 'important_data.csv'), 'w') { |csv| data_hash.to_a.each { |elem| csv << elem} }

  File.open(File.join(simulation_dir, 'gatling_sim_data.csv'), 'w') do |file|
    config.nodes.each do |node|
      file.write("#{node.groupname},#{node.instances},#{node.repetitions}\n")
    end
  end
  puts "Files now saved within #{simulation_dir}"
end

# disk, num cpus, speed of cpus, ram
def get_data_hash(data)
  facts = ['processor0', 'processorcount', 'puppetversion', 'blockdevice_sda_size', 'memorysize']
  data.split("\n").reduce({}) do |result, line|
    hash = line.split(/ => /)
    if facts.include? hash[0]
      result[hash[0]] = hash[1]
    end
    result
  end
end

def get_git_data(git_dir)
  if git_dir == 'puppet-acceptance'
    `git rev-parse HEAD`
  elsif git_dir == 'gatling-puppet-load-test'
    `git --git-dir=../../.git rev-parse HEAD`
  end
end

# Begin work

puts "Gathering facter data and processing data..."
config = Puppet::Gatling::LoadTest::ScenarioConfig.config_instance

facter_data = get_facter_data
data_hash = get_data_hash facter_data

pa_git_rev = get_git_data 'puppet-acceptance'
data_hash['puppet-acceptance'] = pa_git_rev.chomp
puts "puppet-acceptance HEAD: #{data_hash['puppet-acceptance']}"

pgl_git_rev = get_git_data 'gatling-puppet-load-test'
data_hash['gatling-puppet-load-test'] = pgl_git_rev.chomp
puts "gatling-puppet-load-test HEAD: #{data_hash['gatling-puppet-load-test']}"

save_data(facter_data, data_hash, config)
