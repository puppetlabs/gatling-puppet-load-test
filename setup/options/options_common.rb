# frozen_string_literal: true

{
  ssh: {
    keys: ["id_rsa_acceptance", "#{ENV['HOME']}/.ssh/id_rsa-acceptance"]
  },
  helper: [
    "setup/helpers/classification_helper.rb",
    "setup/helpers/ldap_helper.rb",
    "setup/helpers/gatling_config_helper.rb"
  ],
  xml: true,
  timesync: false,
  repo_proxy: true,
  add_el_extras: false,
  forge_host: "forge-aio01-petest.puppetlabs.com",
  'master-start-curl-retries': 30
}
