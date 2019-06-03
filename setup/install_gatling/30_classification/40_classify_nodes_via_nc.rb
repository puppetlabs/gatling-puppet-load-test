# frozen_string_literal: true

test_name "Classify PE agents via Node Classifier" do
  skip_test "Installing FOSS, not PE" unless ENV["BEAKER_INSTALL_TYPE"] == "pe"
  classify_nodes_via_nc
end
