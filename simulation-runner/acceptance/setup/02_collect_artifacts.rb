# 02_collect_artifacts.rb
# Collect artifacts from machines
# Brian Cain {brian.cain@puppetlabs.com}

require 'csv'

def get_facter_data
  result = on master, "facter"
  result.stdout
end

def save_data(facter_data, data_hash)
  unless File.exist?('puppet-gatling')
    FileUtils.mkdir 'puppet-gatling'
  end

  File.open('puppet-gatling/facter-data.txt', 'w') { |file| file.write(facter_data) }
  CSV.open('puppet-gatling/important_data.csv', 'w') { |csv| data_hash.to_a.each { |elem| csv << elem} }
  puts "Files now saved within puppet-gatling/"
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
  `git --git-dir=#{git_dir}/.git rev-parse HEAD`
end

# Begin work

puts "Gathering facter data and processing data..."
facter_data = get_facter_data
data_hash = get_data_hash facter_data

pa_git_rev = get_git_data 'puppet-acceptance'
data_hash['puppet-acceptance'] = pa_git_rev.chomp
pgl_git_rev = get_git_data 'gatling-puppet-load-test'
data_hash['gatling-puppet-load-test'] = pgl_git_rev.chomp

save_data(facter_data, data_hash)
