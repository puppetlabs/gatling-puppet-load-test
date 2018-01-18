require 'scooter'
test_name 'Enable file_sync' do
  api = Scooter::HttpDispatchers::ConsoleDispatcher.new(dashboard)
  pe_master_group = api.get_node_group_by_name('PE Master')
  pe_master_group['classes']['puppet_enterprise::profile::master']['file_sync_enabled'] = true
  api.replace_node_group(pe_master_group['id'], pe_master_group)
  on(master, 'puppet agent -t', :acceptable_exit_codes => [0,2])
end
