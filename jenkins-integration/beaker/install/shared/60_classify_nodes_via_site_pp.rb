require 'puppet/gatling/config'

test_name "Classify Puppet agents on master"

def generate_sitepp(node_configs)
  node_configs.map do |config|
    config['classes'].
      map { |klass| "include #{klass}" }.
      insert(0, "node /#{config['certname_prefix']}.*/ {").
      push('}').
      join("\n")
  end.join("\n").strip
end

def classify_foss_nodes(host, nodes)
  environments = on(host, puppet('config print environmentpath')).stdout.chomp
  # on old PEs (3.3 at least), directory environments have to be enabled. We
  # can detect this situation because the command above will return an empty
  # string.  In that case we'll take a swing at enabling them by modifying the
  # puppet config file, and then running the command again.
  #
  # This may need to be changed to support more versions of PE and/or OSS in
  # the future.
  if environments == ""
    on(host, puppet('config set environmentpath \$confdir/environments'))
    # need to restart the server to make this change take effect.
    # TODO: should move the restart into a helper method or something, this
    # is duplicated in 99_restart_server.rb.
    service_name = ENV['PUPPET_SERVER_SERVICE_NAME']

    on(host, "systemctl restart #{service_name}")

    Beaker::Log.notify("Finished restarting service #{service_name}")

    # now update the value for environments dir
    environments = on(host, puppet('config print environmentpath')).stdout.chomp
  end
  nodes = group_by_environment(nodes)
  nodes.each_pair do |env, node_configs|
    manifestdir = "#{environments}/#{env}/manifests"
    manifestfile = "#{manifestdir}/site.pp"
    Beaker::Log.notify("Saving node configs for env '#{env}' to file '#{manifestfile}'")
    sitepp = generate_sitepp(node_configs)

    on(host, "mkdir -p #{manifestdir}")
    create_remote_file(host, manifestfile, sitepp)
    on(host, "chmod 644 #{manifestfile}")
    on(host, "cat #{manifestfile}")
  end
end

nodes = node_configs(get_scenario_from_env())
classify_foss_nodes(master, nodes)
