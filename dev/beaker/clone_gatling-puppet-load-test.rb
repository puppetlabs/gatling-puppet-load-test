test_name "Clone the gatling-puppet-load-test repo on the target machine"

repo = "gatling-puppet-load-test"
repo_url = "https://github.com/puppetlabs/#{repo}.git"

step "Clone #{repo_url}"
# Skip if directory already exists
on(dev_machine, "test -d ~/#{repo}", :acceptable_exit_codes => [0, 1]) do |result|
  if result.exit_code == 0
    skip_test "Repo already exists on host"
  else
    on(dev_machine, "git clone #{repo_url} ~/#{repo}")
  end
end
