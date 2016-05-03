test_name "Apply puppet role for driver node in dev env"

step "Apply role on dev machine" do
  on(jenkins, puppet("apply", "-e", "'include ::puppetserver_perf_driver::role::puppetserver::perf::driver::dev'"))
end
