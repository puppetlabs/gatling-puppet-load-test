test_name 'Clone the gatling-puppet-load-test repo onto jenkings-gatling'

repo = "gatling-puppet-load-test"
repo_url = "https://github.com/puppetlabs/#{repo}.git"

# Skip if directory already exists
on(jenkins, "test -d ~/#{repo} || git clone #{repo_url} ~/#{repo}")
