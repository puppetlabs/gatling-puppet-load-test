test_name "Classify Puppet agents on master"
skip_test 'Installing PE, not FOSS' unless ENV['BEAKER_INSTALL_TYPE'] == 'foss'

def generate_sitepp()
  <<-sitepp
node /.*agent.*/ { include #{ENV['PUPPET_SCALE_CLASS']} }
node 'default' {}
  sitepp
end

def classify_foss_nodes(host)
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
    service_name = get_puppet_server_service_name_from_env()

    on(host, "systemctl restart #{service_name}")

    Beaker::Log.notify("Finished restarting service #{service_name}")

    # now update the value for environments dir
    environments = on(host, puppet('config print environmentpath')).stdout.chomp
  end
    manifestdir = "#{environments}/production/manifests"
    manifestfile = "#{manifestdir}/site.pp"
    Beaker::Log.notify("Saving node configs for env 'production' to file '#{manifestfile}'")
    sitepp = generate_sitepp()

    on(host, "mkdir -p #{manifestdir}")
    create_remote_file(host, manifestfile, sitepp)
    on(host, "chmod 644 #{manifestfile}")
    on(host, "cat #{manifestfile}")
end

classify_foss_nodes(master)
