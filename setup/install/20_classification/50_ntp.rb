require 'classification_helper'

def add_ntp_group
  ntp_group = {
    'name'    => "NTP",
    "rule"    =>  [ "and", [ "=", [ "fact", "id" ], "root" ]],
    'parent'  => pe_infra_uuid,
    'classes' => {
      'ntp' => {}
    }
  }

  dispatcher.find_or_create_node_group_model(ntp_group)
end

test_name 'NTP classification' do
  skip_test "Skipping NTP classification in non Scale test deployment" unless options[:scale]

  step 'add NTP classification' do
    # Beaker only syncs time on inital setup, since this is a long running test,
    # Use the ntp module to keep time in sync during the entire test.
    add_ntp_group
  end
end
