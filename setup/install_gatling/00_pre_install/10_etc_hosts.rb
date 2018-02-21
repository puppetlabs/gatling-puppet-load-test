test_name 'set loadbalancer as puppet in /etc/hosts' do
  step 'modify /etc/hosts' do
    set_etc_hosts
  end
end
