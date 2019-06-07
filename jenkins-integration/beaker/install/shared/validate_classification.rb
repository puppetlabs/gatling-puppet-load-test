# frozen_string_literal: true

require "puppet/gatling/config"
require "json"

test_name "Validate node classification"

## ASSUMPTIONS:
## - agent certs/keys are already on the master in the $ssldir (SERVER-787)

def check_for_classes(catalog_response, config)
  expected = config["classes"]
  actual = catalog_response["classes"]
  all_found = expected.all? { |klass| actual.include?(klass) }
  abort "Node '#{config['certname']}' missing classes.\nExpected: #{expected}\nActual: #{actual}" unless all_found
end

def build_catalog_query(host, node_config, server, cacert)
  certname = node_config["certname"]
  cert = on(host, puppet("config print hostcert --certname #{certname}")).stdout.chomp
  key = on(host, puppet("config print hostprivkey --certname #{certname}")).stdout.chomp
  environment = node_environment(node_config)
  url = "https://#{server}:8140/puppet/v3/catalog/#{certname}\?environment=#{environment}"
  "curl --cert #{cert} --key #{key} --cacert #{cacert} #{url}"
end

def validate_classification(host, nodes)
  server = on(host, puppet("config print certname")).stdout.chomp
  cacert = on(host, puppet("config print localcacert")).stdout.chomp
  nodes.each do |config|
    catalog_query = build_catalog_query(host, config, server, cacert)
    response = on(host, catalog_query).stdout.chomp
    check_for_classes(JSON.parse(response), config)
  end
end

nodes = node_configs(get_scenario_from_env)
validate_classification(master, nodes)
