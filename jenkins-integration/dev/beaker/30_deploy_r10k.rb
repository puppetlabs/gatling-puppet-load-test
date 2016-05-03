test_name "Deploy r10k control repo"

def run_r10k_deploy(host)
  r10k = '/opt/puppetlabs/puppet/bin/r10k'
  on(host, "#{r10k} deploy environment --puppetfile --verbose")
end

run_r10k_deploy(jenkins)
