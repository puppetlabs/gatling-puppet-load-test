# frozen_string_literal: true

test_name "Classify Puppet agents on master" do
  skip_test "Only runs on FOSS" unless ENV["BEAKER_INSTALL_TYPE"] == "foss"

  # Remove classifier data sources from the hiera configs on foss
  hiera_configs = []

  hc_global = puppet_config(master, "hiera_config")
  hiera_configs << hc_global if master.file_exist?(hc_global)

  env_path = puppet_config(master, "environmentpath")
  env = puppet_config(master, "environment")
  hc_env = [env_path, env, "hiera.yaml"].join("/")
  hiera_configs << hc_env if master.file_exist?(hc_env)

  hiera_configs.each do |hiera_config|
    config = YAML.safe_load(on(master, "cat #{hiera_config}").stdout)
    config["hierarchy"].reject! { |backend| backend["name"] =~ /Classifier/i }
    create_remote_file(master, hiera_config, config.to_yaml)
  end

  classify_foss_nodes(master)
  setup_puppet_metrics_collector_for_foss
end
