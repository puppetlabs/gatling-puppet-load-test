test_name "Apply manifests for jenkins, sbt, jjb, etc"

## Development and debugging of the manifests is easier if we first copy all
## of them over before we start applying them. That way if one fails to apply
## we can SSH into the machine and have access to all of them so we can run
## "puppet apply" on them directly and in different orders.

tmpdir = create_tmpdir_on(jenkins)

step "Copy all manifests to dev machine" do
  Dir['manifests/*.pp'].each do |manifest|
    remotepath = "#{tmpdir}/#{File.basename(manifest)}"
    scp_to(jenkins, manifest, remotepath)
  end
end

manifests_to_apply = [
  "setup_jenkins.pp",
  "setup_jjb.pp",
  "setup_sbt.pp",
  "setup_ruby.pp",
]

step "Apply manifests on dev machine" do
  manifests_to_apply.each do |manifest|
    remotepath = "#{tmpdir}/#{manifest}"
    stderr = on(jenkins, puppet_apply(remotepath)).stderr
    assert_no_match(/Error:/, stderr, 'Unexpected error was detected!')
  end
end
