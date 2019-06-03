# frozen_string_literal: true

test_name "Apply puppet role for driver node in dev env"

step "Apply role on dev machine" do
  # NOTE: this code is what actually triggers the initialization of the dev driver
  #  node.  Here we point it to the 'production' branch of the control repo, but
  #  if you are doing dev work that involves changes to the control repo and/or
  #  to the `puppetlabs-puppetserver_perf_dev` module, you may wish to temporarily
  #  change it to the name of your dev branch of the control repo.  Note that
  #  r10k will automatically substitute underscores for any non-alpha characters
  #  (including slashes) in your branch name, so you need to use the underscore
  #  representation here.
  on(jenkins, puppet("apply", "--environment", "production",
                     "-e", "'include ::puppetserver_perf_driver::role::puppetserver::perf::driver::dev'"))
end
