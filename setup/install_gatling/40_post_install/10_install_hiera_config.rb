require 'tmpdir'
require 'yaml'

test_name 'Install hiera config'

def update_hiera_datadir_in_local_config
  config = YAML.load_file(@local_hiera_config_path)
  config[:yaml][:datadir] = '/etc/puppetlabs/code/environments/production/hieradata/'
  File.open(@local_hiera_config_path, 'w') { |f| f.write(config.to_yaml) }
end

def install_hieraconfig(host)
  scp_to(host, @local_hiera_config_path, @target_hiera_config_path)
  on(host, "chmod 644 #{@target_hiera_config_path}")
end

@source_hiera_config_path = '/etc/puppetlabs/code/environments/production/root_files/hiera.yaml'
@target_hiera_config_path = on(master, puppet('config print hiera_config')).stdout.chomp
local_hiera_dir = Dir.mktmpdir
scp_from(master, @source_hiera_config_path, local_hiera_dir)
@local_hiera_config_path = File.join(local_hiera_dir, 'hiera.yaml')
update_hiera_datadir_in_local_config
install_hieraconfig(master)
