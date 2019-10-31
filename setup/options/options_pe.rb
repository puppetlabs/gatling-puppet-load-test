# frozen_string_literal: true

{
  :type                  => "pe",
  :pre_suite             => [
    # common between foss, pe
    "setup/install_gatling/00_pre_install/05_initialize_helpers.rb",
    "setup/install_gatling/00_pre_install/20_rpm_setup.rb",
    "setup/install_gatling/00_pre_install/30_r10k_git_setup.rb",
    # unique to pe
    "setup/install_gatling/10_pe_install/10_install_pe.rb",
    # unique to pe
    "setup/install_gatling/30_classification/00_configure_code_manager.rb",
    "setup/install_gatling/30_classification/40_classify_nodes_via_nc.rb",
    "setup/install_gatling/30_classification/45_classify_master_via_nc.rb",
    # common between foss, pe
    "setup/install_gatling/40_post_install/30_final_puppet_run.rb",
    "setup/install_gatling/40_post_install/40_configure_gatling_auth.rb",
    "setup/install_gatling/40_post_install/50_configure_permissive_server_auth.rb",
    "setup/install_gatling/40_post_install/60_restart_server.rb",
    "setup/install_gatling/40_post_install/70_disable_firewall.rb",
    "setup/install_gatling/40_post_install/80_install_deps.rb",
    "setup/install_gatling/40_post_install/99_setup_gatling_proxy.rb",
    # unique to pe
    "setup/install_gatling/50_tune/10_puppet_infrastructure_tune.rb",
    "setup/install_gatling/99_final/99_final_puppet_run.rb"
  ],
  "is_puppetserver"      => true,
  "use-service"          => true, # use service scripts to start/stop stuff
  "puppetservice"        => "pe-puppetserver",
  "puppetserver-confdir" => "/etc/puppetlabs/puppetserver/conf.d",
  "puppetserver-config"  => "/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf"
}.merge(eval(File.read("setup/options/options_common.rb"))) # rubocop:disable Security/Eval
