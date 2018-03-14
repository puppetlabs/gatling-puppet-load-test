test_name 'Run puppet agent on the master to prime directories' do
  # Before kicking off a Gatling run, we run the agent on the master against
  # itself one time.  This ensures that the master will create any directories
  # in which it will need to store artifacts for future agent runs.  Doing this
  # ahead of the Gatling run avoids collisions in the priming that can happen
  # when multiple agent runs happen at the same time.  See PUP-6651 for more
  # information.
  #
  # We have to use `hostname` here instead of "master" because some of the
  # perf blades use their razor ID as their hostname instead of the node
  # name used by beaker, which comes from DNS.
  on(master, "puppet agent -t --server `hostname`")
end
