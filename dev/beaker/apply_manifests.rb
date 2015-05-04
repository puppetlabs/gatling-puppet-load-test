test_name "Apply manifests for jenkins/git, sbt, and jjb"

manifests = [Dir.glob("../manifests/*.pp")]

hosts.each do |host|
  manifests.each do |local_path|
    manifest_name = File.basename(local_path)
    remote_path = File.join("/tmp/", manifest_name)

    step "Send #{manifest_name} to host"
    scp_to(host, local_path, remote_path)

    step "Apply #{manifest_name} manifest"
    on(host, "puppet apply #{remote_path}")
  end
end
