# frozen_string_literal: true

require "classification_helper"

def add_metrics_groups
  metrics_host = metric.node_name
  metrics_ip = metric.ip

  collectd_group = {
    "name"    => "CollectD",
    "rule"    => ["and", ["=", %w[fact id], "root"]],
    "parent"  => pe_infra_uuid,
    "classes" => {}
  }
  metrics_group = {
    "name"    => "Metrics Server",
    "rule"    => ["or", ["=", "name", metrics_host]], # pinned node
    "parent"  => pe_infra_uuid,
    "classes" => {}
  }
  endpoint_group = {
    "name"    => "Metrics Endpoint Data Collection",
    "rule"    => ["or", ["=", "name", master.node_name]], # pinned node
    "parent"  => pe_infra_uuid,
    "classes" => { "pe_metric_curl_cron_jobs" => {
      "puppetserver_hosts" => select_hosts(roles: %w[master compile_master]),
      "puppetdb_hosts"     => select_hosts(roles: ["database"])
    } }
  }

  collectd_group["classes"]["collectd"] = {}
  collectd_group["classes"]["collectd::plugin::cpu"] = {}
  collectd_group["classes"]["collectd::plugin::disk"] = {}
  collectd_group["classes"]["collectd::plugin::memory"] = {}
  collectd_group["classes"]["collectd::plugin::write_graphite"] = { "graphitehost" => metrics_host }
  metrics_group["classes"]["profile::metrics_web"] = { "grafana_host" => metrics_ip, "graphite_host" => metrics_ip }
  dispatcher.find_or_create_node_group_model(collectd_group)
  dispatcher.find_or_create_node_group_model(metrics_group)
  dispatcher.find_or_create_node_group_model(endpoint_group)
end

test_name "Metrics classification" do
  skip_test "No metrics host specified" unless any_hosts_as?(:metric)

  step "add metrics classification" do
    add_metrics_groups if any_hosts_as?(:metric)
  end
end
