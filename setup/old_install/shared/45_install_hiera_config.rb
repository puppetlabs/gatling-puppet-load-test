require 'puppet/gatling/config'
require 'tmpdir'
require 'yaml'

test_name 'Install hiera config'

def target_hiera_config_path(host)
  return on(host, puppet('config print hiera_config')).stdout.chomp
end

def get_source_hiera_config(host, hiera_config)
  source_hiera_config_path = hiera_config[:source_file]
  if source_hiera_config_path.nil? || source_hiera_config_path.empty?
    source_hiera_config_path = target_hiera_config_path(host)
  end
  local_hiera_dir = Dir.mktmpdir
  scp_from(master, source_hiera_config_path, local_hiera_dir)
  File.join(local_hiera_dir, File.basename(source_hiera_config_path))
end

def update_hiera_datadir_in_local_config(host, hiera_config, local_hiera_config_path)
  datadir = hiera_config[:datadir]
  if !datadir.nil? && !datadir.empty?
    config = YAML.load_file(local_hiera_config_path)
    config[:yaml][:datadir] = datadir
    File.open(local_hiera_config_path, 'w') { |f| f.write(config.to_yaml) }
  end
end

def install_hieraconfig(host, source_path)
  target_path = target_hiera_config_path(host)
  scp_to(host, source_path, target_path)
  on(host, "chmod 644 #{target_path}")
end

hiera_config = get_hiera_config_from_env()
local_hiera_config_path = get_source_hiera_config(master, hiera_config)
update_hiera_datadir_in_local_config(master, hiera_config, local_hiera_config_path)
install_hieraconfig(master, local_hiera_config_path)
