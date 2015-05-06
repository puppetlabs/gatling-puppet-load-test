test_name "Clone the gatling-puppet-load-test repo on the target machine"

repo = "gatling-puppet-load-test"
repo_url = "https://github.com/puppetlabs/#{repo}.git"

step "Clone #{repo_url}"
on(dev_machine, "git clone #{repo_url} ~/#{repo}")
