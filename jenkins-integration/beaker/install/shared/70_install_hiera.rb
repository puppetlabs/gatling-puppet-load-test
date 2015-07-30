require 'puppet/gatling/config'

test_name 'Install Hiera data'

def install_hieraconfig(host, hiera)
  configfile = hiera_configpath(hiera)
  configpath = on(host, puppet('config print hiera_config')).stdout.chomp
  scp_to(host, configfile, configpath)
end

def install_hieradata(host, hiera)
  datadirs = hiera_datadirs(hiera)
  datadirs.each do |localpath, hostpath|
    targetpath = File.dirname(hostpath)
    scp_to(host, localpath, targetpath)
  end
end

scenario_id = ENV['PUPPET_GATLING_SCENARIO']
hiera = parse_scenario_file(scenario_id)['hiera']
if not hiera.nil?
  install_hieraconfig(master, hiera)
  install_hieradata(master, hiera)
end
