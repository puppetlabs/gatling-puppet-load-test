# frozen_string_literal: true

test_name "Classify PE agents via Node Classifier" do
  skip_test "Installing FOSS, not PE" unless ENV["BEAKER_INSTALL_TYPE"] == "pe"
  classify_nodes_via_nc

  # create non-perf-agent-group and use it to add ntp
  classifier.find_or_create_node_group_model(
    "parent"  => "00000000-0000-4000-8000-000000000000",
    "name"    => "non-perf-agent-group",
    "rule"    => ["and", ["not", ["~", %w[fact clientcert], ".*agent.*"]]],
    "classes" => { "ntp" => { servers: ["pool.ntp.org"] } }
  )
end
