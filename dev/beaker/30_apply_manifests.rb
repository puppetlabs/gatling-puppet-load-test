test_name "Apply manifests for jenkins/git, sbt, and jjb"

manifests = [
  "manifests/setup_jenkins.pp",
  "manifests/setup_jjb.pp",
  "manifests/setup_sbt.pp"
]

step "Make a temp dir for manifests"
remote_temp_dir = create_tmpdir_on(dev_machine)

manifests.each do |local_path|
  manifest_name = File.basename(local_path)
  remote_path = File.join(remote_temp_dir, manifest_name)

  step "Send #{manifest_name} to #{dev_machine}"
  scp_to(dev_machine, local_path, remote_path)

  step "Apply #{manifest_name} manifest"
  on(dev_machine, "puppet apply #{remote_path}") do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end
  
end

