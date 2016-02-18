require 'puppet/gatling/config'

test_name "Classify Puppet agents on master"

def generate_sitepp(node_configs)
  node_configs.map do |config|
    config['classes'].
      map { |klass| "include #{klass}" }.
      insert(0, "node '#{config['certname']}' {").
      push('}').
      join("\n")
  end.join("\n").strip
end

def classify_foss_nodes(host, nodes)
  environments = on(host, puppet('config print environmentpath')).stdout.chomp
  nodes = group_by_environment(nodes)
  nodes.each_pair do |env, node_configs|
    sitepp = generate_sitepp(node_configs)
    manifestdir = "#{environments}/#{env}/manifests"
    on(host, "mkdir -p #{manifestdir}")
    create_remote_file(host, "#{manifestdir}/site.pp", sitepp)
    on(host, "chmod 644 #{manifestdir}/site.pp")
  end
end

nodes = node_configs(get_scenario_from_env())
classify_foss_nodes(master, nodes)
