# Collect artifacts from machines
# Brian Cain {brian.cain@puppetlabs.com}

require 'puppet/gatling/config'
require 'csv'
require 'json'

def get_facter_data
  result = on master, "facter -p -j"
  result.stdout
end

def save_data(facter_data, data_hash, simulation_id, config)
  simulation_dir = File.join("..", "puppet-gatling", simulation_id)
  unless File.exist?(simulation_dir)
    FileUtils.mkdir_p simulation_dir
  end

  File.open(File.join(simulation_dir, 'facter-data.json'), 'w') { |file| file.write(facter_data) }
  CSV.open(File.join(simulation_dir, 'important_data.csv'), 'w') { |csv| data_hash.to_a.each { |elem| csv << elem} }

  File.open(File.join(simulation_dir, 'gatling_sim_data.csv'), 'w') do |file|
    config["nodes"].each do |node|
      file.write("#{File.basename(node["node_config"], ".json")},#{node["num_instances"]},#{node["num_repetitions"]}\n")
    end
  end
  puts "Files now saved within #{simulation_dir}"
end

# disk, num cpus, speed of cpus, ram
def get_data_hash_from_structured_facts(data)
  facts_data = JSON.parse(data)
  {
      'processor0' => facts_data['processors']['models'][0],
      'processorcount' => facts_data['processors']['count'],
      'puppetversion' => facts_data['puppetversion'],
      'blockdevice_sda_size' => facts_data['disks']['sda']['size'],
      'memorysize' => facts_data['memory']['system']['total']
  }
end

def get_data_hash_from_legacy_facts(data)
  facts_data = JSON.parse(data)
  {
      'processor0' => facts_data['processor0'],
      'processorcount' => facts_data['processorcount'],
      'puppetversion' => facts_data['puppetversion'],
      'blockdevice_sda_size' => facts_data['blockdevice_sda_size'],
      'memorysize' => facts_data['memorysize']
  }
end

# Begin work

puts "Gathering facter data and processing data..."
config = parse_scenario_file(get_scenario_from_env())
simulation_id = get_simulation_id_from_env()

facter_data = get_facter_data()
data_hash =
  if ENV["FACTER_STRUCTURED_FACTS"] == "true"
    get_data_hash_from_structured_facts(facter_data)
  else
    get_data_hash_from_legacy_facts(facter_data)
  end

pgl_git_rev = `git rev-parse HEAD`
data_hash['gatling-puppet-load-test'] = pgl_git_rev.chomp
puts "gatling-puppet-load-test HEAD: #{data_hash['gatling-puppet-load-test']}"

beaker_version = `bundle exec gem list ^beaker$ |grep beaker`.chomp
data_hash['beaker-version'] = beaker_version
puts "Beaker version: #{beaker_version}"

save_data(facter_data, data_hash, simulation_id, config)
