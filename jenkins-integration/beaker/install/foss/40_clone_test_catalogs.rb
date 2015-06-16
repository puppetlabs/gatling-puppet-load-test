require 'fileutils'
require 'tmpdir'

test_name 'Clone test-catalogs repo onto master'

# This is awful - we clone locally and then SCP the whole thing over.
# See QENG-2556 for adding a proper way to do this in Beaker.
tmp_repo = Dir.mktmpdir('test-catalogs')
target = '/root/test-catalogs'

teardown do
  FileUtils.remove_dir(tmp_repo)
end

repo_url = 'git@github.com:puppetlabs/test-catalogs.git'
%x(git clone #{repo_url} #{tmp_repo} --depth 1)

on(master, "test -d #{target} && rm -rf #{target} || true")
scp_to(master, tmp_repo, target)
