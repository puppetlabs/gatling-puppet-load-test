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
  simulation_dir = File.join("..", "puppet-gatling", config.simulation_id)
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

# Begin work

puts "Gathering facter data and processing data..."
config = Puppet::Gatling::LoadTest::ScenarioConfig.config_instance

facter_data = get_facter_data
data_hash = get_data_hash facter_data

pgl_git_rev = `git rev-parse HEAD`
data_hash['gatling-puppet-load-test'] = pgl_git_rev.chomp
puts "gatling-puppet-load-test HEAD: #{data_hash['gatling-puppet-load-test']}"

beaker_version = `bundle exec gem list beaker |grep beaker`.chomp
data_hash['beaker-version'] = beaker_version
puts "Beaker version: #{beaker_version}"

save_data(facter_data, data_hash, config)
